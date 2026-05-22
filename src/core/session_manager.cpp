#include <torrex/session_manager.hpp>

#include <libtorrent/add_torrent_params.hpp>
#include <libtorrent/alert_types.hpp>
#include <libtorrent/load_torrent.hpp>
#include <libtorrent/magnet_uri.hpp>
#include <libtorrent/read_resume_data.hpp>
#include <libtorrent/session.hpp>
#include <libtorrent/settings_pack.hpp>
#include <libtorrent/torrent_flags.hpp>
#include <libtorrent/torrent_handle.hpp>
#include <libtorrent/torrent_status.hpp>
#include <libtorrent/session_params.hpp>
#include <libtorrent/write_resume_data.hpp>

#include <chrono>
#include <cctype>
#include <deque>
#include <filesystem>
#include <fstream>
#include <mutex>
#include <optional>
#include <sstream>
#include <thread>
#include <unordered_map>

namespace torrex {

namespace {

std::string hash_key(const lt::info_hash_t& hashes)
{
    std::ostringstream out;
    if (hashes.has_v1()) {
        out << hashes.v1;
    } else if (hashes.has_v2()) {
        out << hashes.v2;
    }
    return out.str();
}

std::string resume_filename_key(const std::string& key)
{
    std::string out;
    out.reserve(key.size());
    for (const char c : key) {
        if (std::isalnum(static_cast<unsigned char>(c)) != 0) {
            out.push_back(c);
        }
    }
    return out.empty() ? std::string("unknown") : out;
}

TorrentState map_state(const lt::torrent_status::state_t state)
{
    using lt::torrent_status;
    switch (state) {
    case torrent_status::checking_files:
        return TorrentState::Checking;
    case torrent_status::downloading:
    case torrent_status::checking_resume_data:
    case torrent_status::downloading_metadata:
        return TorrentState::Downloading;
    case torrent_status::finished:
    case torrent_status::seeding:
        return TorrentState::Seeding;
    default:
        break;
    }
    return TorrentState::Idle;
}

TorrentSnapshot snapshot_from_status(const lt::torrent_status& st)
{
    TorrentSnapshot snap;
    snap.info_hash.v1_hex = hash_key(st.info_hashes);
    snap.name = st.name;
    if (snap.name.empty()) {
        snap.name = "Torrent";
    }
    snap.state = map_state(st.state);
    snap.downloaded = st.total_done;
    snap.total = st.total_wanted > 0 ? st.total_wanted : st.total_wanted_done;
    snap.progress_percent = static_cast<int>(st.progress * 100.F + 0.5F);
    if (snap.progress_percent == 0 && snap.total > 0 && snap.downloaded > 0) {
        snap.progress_percent =
            static_cast<int>((snap.downloaded * 100) / snap.total);
    }
    snap.download_rate = st.download_rate;
    snap.upload_rate = st.upload_rate;
    snap.save_path = st.save_path;
    if (st.errc) {
        snap.state = TorrentState::Error;
    }
    return snap;
}

int priority_to_int(const lt::download_priority_t priority)
{
    return static_cast<int>(static_cast<std::uint8_t>(priority));
}

void fill_files(const lt::torrent_handle& handle, TorrentSnapshot& snap)
{
    snap.files.clear();
    snap.sequential_download = false;
    const std::shared_ptr<const lt::torrent_info> info = handle.torrent_file();
    if (!info) {
        return;
    }
    snap.sequential_download =
        (handle.flags() & lt::torrent_flags::sequential_download) != lt::torrent_flags_t{};
    const lt::file_storage& storage = info->files();
    snap.files.reserve(static_cast<std::size_t>(storage.num_files()));
    for (lt::file_index_t i : storage.file_range()) {
        TorrentFileSnapshot file;
        file.index = static_cast<int>(i);
        file.path = storage.file_path(i);
        file.priority = priority_to_int(handle.file_priority(i));
        snap.files.push_back(std::move(file));
    }
}

void apply_snapshot_from_handle(const lt::torrent_handle& handle, TorrentSnapshot& snap)
{
    snap = snapshot_from_status(handle.status());
    if ((handle.flags() & lt::torrent_flags::paused) != lt::torrent_flags_t{}) {
        snap.state = TorrentState::Paused;
    }
    fill_files(handle, snap);
}

void apply_proxy_settings(lt::settings_pack& pack, const SessionSettings& settings)
{
    if (settings.proxy_type == kProxyTypeNone || settings.proxy_host.empty()) {
        pack.set_int(lt::settings_pack::proxy_type, lt::settings_pack::none);
        return;
    }

    const int port = settings.proxy_port > 0 ? settings.proxy_port : 1080;
    if (settings.proxy_type == kProxyTypeHttp) {
        pack.set_int(lt::settings_pack::proxy_type, lt::settings_pack::http);
    } else {
        pack.set_int(lt::settings_pack::proxy_type, lt::settings_pack::socks5);
    }
    pack.set_str(lt::settings_pack::proxy_hostname, settings.proxy_host);
    pack.set_int(lt::settings_pack::proxy_port, port);
    pack.set_str(lt::settings_pack::proxy_username, settings.proxy_username);
    pack.set_str(lt::settings_pack::proxy_password, settings.proxy_password);
    pack.set_bool(lt::settings_pack::proxy_peer_connections, settings.proxy_peer_connections);
    pack.set_bool(lt::settings_pack::proxy_tracker_connections, settings.proxy_tracker_connections);
}

std::string ensure_save_path(const std::string& save_path)
{
    if (save_path.empty()) {
        return "Save path is empty.";
    }
    std::error_code ec;
    std::filesystem::create_directories(save_path, ec);
    if (ec) {
        return "Could not create save directory: " + ec.message();
    }
    return {};
}

std::vector<char> read_file_bytes(const std::string& path)
{
    std::ifstream in(path, std::ios::binary);
    if (!in) {
        return {};
    }
    return std::vector<char>(std::istreambuf_iterator<char>(in),
                            std::istreambuf_iterator<char>());
}

bool write_file_bytes(const std::filesystem::path& path, const std::vector<char>& data)
{
    std::error_code ec;
    std::filesystem::create_directories(path.parent_path(), ec);
    std::ofstream out(path, std::ios::binary | std::ios::trunc);
    if (!out) {
        return false;
    }
    if (!data.empty()) {
        out.write(data.data(), static_cast<std::streamsize>(data.size()));
    }
    return out.good();
}

std::string listen_interfaces_for_port(const int port)
{
    std::ostringstream out;
    out << "0.0.0.0:" << port << ",[::]:" << port;
    return out.str();
}

SessionSettings clamp_settings(SessionSettings settings)
{
    if (settings.listen_port < kMinListenPort || settings.listen_port > kMaxListenPort) {
        settings.listen_port = 6881;
    }
    if (settings.download_rate_limit < 0) {
        settings.download_rate_limit = 0;
    }
    if (settings.upload_rate_limit < 0) {
        settings.upload_rate_limit = 0;
    }
    if (settings.proxy_type < kProxyTypeNone || settings.proxy_type > kProxyTypeHttp) {
        settings.proxy_type = kProxyTypeNone;
    }
    if (settings.proxy_port < 0 || settings.proxy_port > kMaxListenPort) {
        settings.proxy_port = 1080;
    }
    return settings;
}

int clamp_file_priority(const int priority)
{
    if (priority < 0) {
        return 0;
    }
    if (priority > 7) {
        return 7;
    }
    return priority;
}

} // namespace

struct SessionManager::Impl {
    std::string data_directory;
    SessionSettings settings{};
    std::optional<lt::session> session;
    mutable std::mutex mutex;
    std::thread worker;
    std::atomic<bool> stop{false};
    int pending_resume_saves = 0;

    struct TorrentEntry {
        lt::torrent_handle handle;
        TorrentSnapshot snapshot;
    };

    std::unordered_map<std::string, TorrentEntry> torrents;

    enum class CommandType {
        AddMagnet,
        AddFile,
        Pause,
        Resume,
        Remove,
        SetFilePriority,
        SetSequential,
    };
    struct Command {
        CommandType type;
        std::string primary;
        std::string save_path;
        bool delete_files = false;
        int file_index = -1;
        int priority = 0;
        bool sequential = false;
    };

    std::deque<Command> commands;
    std::mutex command_mutex;
    std::string last_error;

    [[nodiscard]] std::filesystem::path torrents_dir() const
    {
        return std::filesystem::path(data_directory) / "torrents";
    }

    [[nodiscard]] std::filesystem::path resume_path_for_key(const std::string& key) const
    {
        return torrents_dir() / (resume_filename_key(key) + ".resume");
    }

    void delete_resume_file(const std::string& key)
    {
        if (data_directory.empty()) {
            return;
        }
        std::error_code ec;
        std::filesystem::remove(resume_path_for_key(key), ec);
    }

    void apply_settings_to_session()
    {
        if (!session) {
            return;
        }
        lt::settings_pack pack = session->get_settings();
        pack.set_int(lt::settings_pack::download_rate_limit, settings.download_rate_limit);
        pack.set_int(lt::settings_pack::upload_rate_limit, settings.upload_rate_limit);
        pack.set_str(lt::settings_pack::listen_interfaces,
                     listen_interfaces_for_port(settings.listen_port));
        pack.set_bool(lt::settings_pack::enable_dht, settings.enable_dht);
        pack.set_bool(lt::settings_pack::enable_lsd, settings.enable_lsd);
        pack.set_bool(lt::settings_pack::enable_upnp, settings.enable_upnp);
        pack.set_bool(lt::settings_pack::enable_natpmp, settings.enable_natpmp);
        apply_proxy_settings(pack, settings);
        session->apply_settings(pack);
    }

    void set_error(std::string message)
    {
        std::scoped_lock lock(mutex);
        last_error = std::move(message);
    }

    void enqueue(Command cmd)
    {
        std::scoped_lock lock(command_mutex);
        commands.push_back(std::move(cmd));
    }

    void enqueue_torrent_op(CommandType type, const std::string& info_hash_hex,
                            bool delete_files = false)
    {
        Command cmd;
        cmd.type = type;
        cmd.primary = info_hash_hex;
        cmd.delete_files = delete_files;
        enqueue(std::move(cmd));
    }

    void update_entry(const lt::torrent_handle& handle)
    {
        if (!handle.is_valid()) {
            return;
        }
        lt::torrent_status st = handle.status();
        const std::string key = hash_key(st.info_hashes);
        if (key.empty()) {
            return;
        }
        std::scoped_lock lock(mutex);
        auto& entry = torrents[key];
        entry.handle = handle;
        apply_snapshot_from_handle(handle, entry.snapshot);
    }

    lt::torrent_handle find_handle_by_id(const std::string& id) const
    {
        std::scoped_lock lock(mutex);
        if (const auto it = torrents.find(id); it != torrents.end()) {
            return it->second.handle;
        }
        for (const auto& [key, entry] : torrents) {
            if (entry.handle.is_valid()
                && key.size() == id.size()
                && std::equal(key.begin(), key.end(), id.begin(),
                              [](const char a, const char b) {
                                  return std::tolower(static_cast<unsigned char>(a))
                                      == std::tolower(static_cast<unsigned char>(b));
                              })) {
                return entry.handle;
            }
            (void)key;
        }
        return {};
    }

    void handle_save_resume_alert(const lt::save_resume_data_alert* alert)
    {
        if (pending_resume_saves > 0) {
            --pending_resume_saves;
        }
        if (data_directory.empty() || !alert) {
            return;
        }
        const std::string key = hash_key(alert->params.info_hashes);
        if (key.empty()) {
            return;
        }
        const std::vector<char> buf = lt::write_resume_data_buf(alert->params);
        write_file_bytes(resume_path_for_key(key), buf);
    }

    void pump_alerts_once()
    {
        if (!session) {
            return;
        }
        std::vector<lt::alert*> alerts;
        session->pop_alerts(&alerts);
        for (lt::alert* raw : alerts) {
            if (auto* a = lt::alert_cast<lt::save_resume_data_alert>(raw)) {
                handle_save_resume_alert(a);
            } else if (auto* a = lt::alert_cast<lt::save_resume_data_failed_alert>(raw)) {
                if (pending_resume_saves > 0) {
                    --pending_resume_saves;
                }
                (void)a;
            } else if (auto* a = lt::alert_cast<lt::add_torrent_alert>(raw)) {
                update_entry(a->handle);
            } else if (auto* a = lt::alert_cast<lt::state_changed_alert>(raw)) {
                update_entry(a->handle);
            } else if (auto* a = lt::alert_cast<lt::torrent_finished_alert>(raw)) {
                update_entry(a->handle);
            } else if (auto* a = lt::alert_cast<lt::metadata_received_alert>(raw)) {
                update_entry(a->handle);
            } else if (auto* a = lt::alert_cast<lt::torrent_removed_alert>(raw)) {
                std::scoped_lock lock(mutex);
                const std::string key = hash_key(a->info_hashes);
                if (!key.empty()) {
                    torrents.erase(key);
                }
            } else if (auto* a = lt::alert_cast<lt::torrent_error_alert>(raw)) {
                update_entry(a->handle);
                set_error(a->error.message());
            }
        }

        {
            std::scoped_lock lock(mutex);
            for (auto& [key, entry] : torrents) {
                if (entry.handle.is_valid()) {
                    apply_snapshot_from_handle(entry.handle, entry.snapshot);
                }
                (void)key;
            }
        }
    }

    void restore_torrents()
    {
        if (!session || data_directory.empty()) {
            return;
        }
        const std::filesystem::path dir = torrents_dir();
        std::error_code ec;
        if (!std::filesystem::is_directory(dir, ec)) {
            return;
        }

        for (const std::filesystem::directory_entry& entry :
             std::filesystem::directory_iterator(dir, ec)) {
            if (!entry.is_regular_file() || entry.path().extension() != ".resume") {
                continue;
            }
            const std::vector<char> buf = read_file_bytes(entry.path().string());
            if (buf.empty()) {
                continue;
            }
            lt::error_code read_ec;
            lt::add_torrent_params params = lt::read_resume_data(buf, read_ec);
            if (read_ec) {
                continue;
            }
            params.flags |= lt::torrent_flags::auto_managed;
            lt::error_code add_ec;
            lt::torrent_handle handle = session->add_torrent(params, add_ec);
            if (handle.is_valid()) {
                update_entry(handle);
            }
        }
    }

    void persist_state()
    {
        if (!session || data_directory.empty()) {
            return;
        }

        std::error_code ec;
        std::filesystem::create_directories(torrents_dir(), ec);

        {
            std::scoped_lock lock(mutex);
            pending_resume_saves = 0;
            for (auto& [key, entry] : torrents) {
                if (entry.handle.is_valid()) {
                    entry.handle.save_resume_data(lt::torrent_handle::save_info_dict);
                    ++pending_resume_saves;
                }
                (void)key;
            }
        }

        const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(5);
        while (pending_resume_saves > 0
               && std::chrono::steady_clock::now() < deadline) {
            pump_alerts_once();
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }

        const lt::session_params state = session->session_state();
        const std::vector<char> session_buf = lt::write_session_params_buf(state);
        write_file_bytes(std::filesystem::path(data_directory) / "session.dat", session_buf);
    }

    void process_commands()
    {
        if (!session) {
            return;
        }

        std::deque<Command> batch;
        {
            std::scoped_lock lock(command_mutex);
            batch.swap(commands);
        }

        for (const Command& cmd : batch) {
            if (cmd.type != CommandType::AddMagnet && cmd.type != CommandType::AddFile) {
                continue;
            }

            const std::string path_err = ensure_save_path(cmd.save_path);
            if (!path_err.empty()) {
                set_error(path_err);
                continue;
            }

            lt::error_code ec;
            lt::add_torrent_params params;

            try {
                if (cmd.type == CommandType::AddMagnet) {
                    params = lt::parse_magnet_uri(cmd.primary, ec);
                    if (ec) {
                        set_error(ec.message());
                        continue;
                    }
                } else {
                    params = lt::load_torrent_file(cmd.primary);
                }
            } catch (const std::exception& ex) {
                set_error(ex.what());
                continue;
            }

            params.save_path = cmd.save_path;
            params.flags |= lt::torrent_flags::auto_managed;

            const std::string key = hash_key(params.info_hashes);
            if (!key.empty()) {
                lt::torrent_handle existing = find_handle_by_id(key);
                if (existing.is_valid()) {
                    update_entry(existing);
                    continue;
                }
            }

            lt::torrent_handle handle = session->add_torrent(params, ec);
            if (ec) {
                lt::torrent_handle existing = find_handle_by_id(key);
                if (!key.empty() && existing.is_valid()) {
                    update_entry(existing);
                    continue;
                }
                set_error(ec.message());
                continue;
            }
            if (handle.is_valid()) {
                update_entry(handle);
            }
        }

        for (const Command& cmd : batch) {
            if (cmd.type != CommandType::Pause && cmd.type != CommandType::Resume
                && cmd.type != CommandType::Remove && cmd.type != CommandType::SetFilePriority
                && cmd.type != CommandType::SetSequential) {
                continue;
            }
            if (cmd.primary.empty()) {
                set_error("Torrent id is empty.");
                continue;
            }

            lt::torrent_handle handle = find_handle_by_id(cmd.primary);
            if (!handle.is_valid()) {
                set_error("Torrent not found.");
                continue;
            }

            if (cmd.type == CommandType::Pause) {
                handle.unset_flags(lt::torrent_flags::auto_managed);
                handle.pause();
            } else if (cmd.type == CommandType::Resume) {
                handle.resume();
                handle.set_flags(lt::torrent_flags::auto_managed);
            } else if (cmd.type == CommandType::SetFilePriority) {
                if (cmd.file_index < 0) {
                    set_error("Invalid file index.");
                    continue;
                }
                handle.file_priority(lt::file_index_t{cmd.file_index},
                                     lt::download_priority_t{
                                         static_cast<std::uint8_t>(clamp_file_priority(cmd.priority))});
            } else if (cmd.type == CommandType::SetSequential) {
                if (cmd.sequential) {
                    handle.set_flags(lt::torrent_flags::sequential_download);
                } else {
                    handle.unset_flags(lt::torrent_flags::sequential_download);
                }
            } else {
                lt::remove_flags_t flags{};
                if (cmd.delete_files) {
                    flags |= lt::session::delete_files;
                }
                session->remove_torrent(handle, flags);
                std::scoped_lock lock(mutex);
                torrents.erase(cmd.primary);
                delete_resume_file(cmd.primary);
            }
            if (cmd.type != CommandType::Remove && handle.is_valid()) {
                update_entry(handle);
            }
        }
    }

    void process_alerts() { pump_alerts_once(); }
};

SessionManager::SessionManager(std::string data_directory)
    : impl_(std::make_unique<Impl>())
{
    impl_->data_directory = std::move(data_directory);
    impl_->settings = clamp_settings(impl_->settings);
}

SessionManager::~SessionManager() { shutdown(); }

void SessionManager::set_session_settings(SessionSettings settings)
{
    impl_->settings = clamp_settings(std::move(settings));
    if (running_.load()) {
        impl_->apply_settings_to_session();
    }
}

SessionSettings SessionManager::session_settings() const
{
    std::scoped_lock lock(impl_->mutex);
    return impl_->settings;
}

const std::string& SessionManager::data_directory() const noexcept
{
    return impl_->data_directory;
}

void SessionManager::start()
{
    if (running_.exchange(true)) {
        return;
    }

    lt::session_params params;
    if (!impl_->data_directory.empty()) {
        const std::filesystem::path session_file =
            std::filesystem::path(impl_->data_directory) / "session.dat";
        if (std::filesystem::is_regular_file(session_file)) {
            const std::vector<char> buf = read_file_bytes(session_file.string());
            if (!buf.empty()) {
                params = lt::read_session_params(buf);
            }
        }
        std::error_code ec;
        std::filesystem::create_directories(impl_->torrents_dir(), ec);
    }

    impl_->session.emplace(std::move(params));
    impl_->apply_settings_to_session();
    impl_->restore_torrents();

    impl_->stop = false;
    impl_->worker = std::thread([this] {
        while (!impl_->stop.load()) {
            impl_->process_commands();
            impl_->process_alerts();
            std::this_thread::sleep_for(std::chrono::milliseconds(50));
        }
    });
}

void SessionManager::shutdown()
{
    if (!running_.exchange(false)) {
        return;
    }

    impl_->stop = true;
    if (impl_->worker.joinable()) {
        impl_->worker.join();
    }

    if (impl_->session) {
        impl_->persist_state();
        impl_->session.reset();
    }

    {
        std::scoped_lock lock(impl_->mutex);
        impl_->torrents.clear();
    }
}

std::vector<TorrentSnapshot> SessionManager::snapshots() const
{
    std::scoped_lock lock(impl_->mutex);
    std::vector<TorrentSnapshot> out;
    out.reserve(impl_->torrents.size());
    for (const auto& [key, entry] : impl_->torrents) {
        (void)key;
        out.push_back(entry.snapshot);
    }
    return out;
}

std::string SessionManager::add_magnet(const std::string& uri, const std::string& save_path)
{
    if (!running_.load()) {
        return "Session is not running.";
    }
    const std::string path_err = ensure_save_path(save_path);
    if (!path_err.empty()) {
        return path_err;
    }

    lt::error_code ec;
    (void)lt::parse_magnet_uri(uri, ec);
    if (ec) {
        return "Invalid magnet URI: " + ec.message();
    }

    Impl::Command cmd;
    cmd.type = Impl::CommandType::AddMagnet;
    cmd.primary = uri;
    cmd.save_path = save_path;
    impl_->enqueue(std::move(cmd));
    return {};
}

std::string SessionManager::add_torrent_file(const std::string& path,
                                             const std::string& save_path)
{
    if (!running_.load()) {
        return "Session is not running.";
    }
    if (!std::filesystem::is_regular_file(path)) {
        return "Torrent file not found.";
    }
    const std::string path_err = ensure_save_path(save_path);
    if (!path_err.empty()) {
        return path_err;
    }

    try {
        (void)lt::load_torrent_file(path);
    } catch (const std::exception& ex) {
        return std::string("Invalid torrent file: ") + ex.what();
    }

    Impl::Command cmd;
    cmd.type = Impl::CommandType::AddFile;
    cmd.primary = path;
    cmd.save_path = save_path;
    impl_->enqueue(std::move(cmd));
    return {};
}

std::string SessionManager::take_last_error()
{
    std::scoped_lock lock(impl_->mutex);
    std::string err = std::move(impl_->last_error);
    impl_->last_error.clear();
    return err;
}

std::string SessionManager::pause_torrent(const std::string& info_hash_hex)
{
    if (!running_.load()) {
        return "Session is not running.";
    }
    if (info_hash_hex.empty()) {
        return "Torrent id is empty.";
    }
    impl_->enqueue_torrent_op(Impl::CommandType::Pause, info_hash_hex);
    return {};
}

std::string SessionManager::resume_torrent(const std::string& info_hash_hex)
{
    if (!running_.load()) {
        return "Session is not running.";
    }
    if (info_hash_hex.empty()) {
        return "Torrent id is empty.";
    }
    impl_->enqueue_torrent_op(Impl::CommandType::Resume, info_hash_hex);
    return {};
}

std::string SessionManager::remove_torrent(const std::string& info_hash_hex,
                                           const bool delete_files)
{
    if (!running_.load()) {
        return "Session is not running.";
    }
    if (info_hash_hex.empty()) {
        return "Torrent id is empty.";
    }
    impl_->enqueue_torrent_op(Impl::CommandType::Remove, info_hash_hex, delete_files);
    return {};
}

std::string SessionManager::set_file_priority(const std::string& info_hash_hex,
                                              const int file_index,
                                              const int priority)
{
    if (!running_.load()) {
        return "Session is not running.";
    }
    if (info_hash_hex.empty()) {
        return "Torrent id is empty.";
    }
    Impl::Command cmd;
    cmd.type = Impl::CommandType::SetFilePriority;
    cmd.primary = info_hash_hex;
    cmd.file_index = file_index;
    cmd.priority = priority;
    impl_->enqueue(std::move(cmd));
    return {};
}

std::string SessionManager::set_sequential_download(const std::string& info_hash_hex,
                                                    const bool enabled)
{
    if (!running_.load()) {
        return "Session is not running.";
    }
    if (info_hash_hex.empty()) {
        return "Torrent id is empty.";
    }
    Impl::Command cmd;
    cmd.type = Impl::CommandType::SetSequential;
    cmd.primary = info_hash_hex;
    cmd.sequential = enabled;
    impl_->enqueue(std::move(cmd));
    return {};
}

} // namespace torrex
