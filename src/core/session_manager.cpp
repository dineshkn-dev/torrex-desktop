#include <torrex/session_manager.hpp>

#include <libtorrent/add_torrent_params.hpp>
#include <libtorrent/alert_types.hpp>
#include <libtorrent/load_torrent.hpp>
#include <libtorrent/magnet_uri.hpp>
#include <libtorrent/session.hpp>
#include <libtorrent/settings_pack.hpp>
#include <libtorrent/torrent_flags.hpp>
#include <libtorrent/torrent_handle.hpp>
#include <libtorrent/torrent_status.hpp>

#include <chrono>
#include <deque>
#include <filesystem>
#include <fstream>
#include <mutex>
#include <cctype>
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

void fill_file_paths(const lt::torrent_handle& handle, TorrentSnapshot& snap)
{
    snap.file_paths.clear();
    const std::shared_ptr<const lt::torrent_info> info = handle.torrent_file();
    if (!info) {
        return;
    }
    const lt::file_storage& files = info->files();
    snap.file_paths.reserve(static_cast<std::size_t>(files.num_files()));
    for (lt::file_index_t i : files.file_range()) {
        snap.file_paths.push_back(files.file_path(i));
    }
}

void apply_snapshot_from_handle(const lt::torrent_handle& handle, TorrentSnapshot& snap)
{
    snap = snapshot_from_status(handle.status());
    if ((handle.flags() & lt::torrent_flags::paused) != lt::torrent_flags_t{}) {
        snap.state = TorrentState::Paused;
    }
    fill_file_paths(handle, snap);
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

} // namespace

struct SessionManager::Impl {
    lt::session session{lt::session_params{}};
    mutable std::mutex mutex;
    std::thread worker;
    std::atomic<bool> stop{false};

    struct TorrentEntry {
        lt::torrent_handle handle;
        TorrentSnapshot snapshot;
    };

    std::unordered_map<std::string, TorrentEntry> torrents;

    enum class CommandType { AddMagnet, AddFile, Pause, Resume, Remove };
    struct Command {
        CommandType type;
        std::string primary;
        std::string save_path;
        bool delete_files = false;
    };

    std::deque<Command> commands;
    std::mutex command_mutex;
    std::string last_error;

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

    void process_commands()
    {
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
            lt::torrent_handle handle = session.add_torrent(params, ec);
            if (ec) {
                set_error(ec.message());
                continue;
            }
            if (handle.is_valid()) {
                update_entry(handle);
            }
        }

        for (const Command& cmd : batch) {
            if (cmd.type != CommandType::Pause && cmd.type != CommandType::Resume
                && cmd.type != CommandType::Remove) {
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
                // auto_managed torrents ignore pause until auto_managed is cleared.
                handle.unset_flags(lt::torrent_flags::auto_managed);
                handle.pause();
            } else if (cmd.type == CommandType::Resume) {
                handle.resume();
                handle.set_flags(lt::torrent_flags::auto_managed);
            } else {
                lt::remove_flags_t flags{};
                if (cmd.delete_files) {
                    flags |= lt::session::delete_files;
                }
                session.remove_torrent(handle, flags);
                std::scoped_lock lock(mutex);
                torrents.erase(cmd.primary);
            }
            if (cmd.type != CommandType::Remove && handle.is_valid()) {
                update_entry(handle);
            }
        }
    }

    void process_alerts()
    {
        std::vector<lt::alert*> alerts;
        session.pop_alerts(&alerts);

        for (lt::alert* raw : alerts) {
            if (auto* a = lt::alert_cast<lt::add_torrent_alert>(raw)) {
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
};

SessionManager::SessionManager() : impl_(std::make_unique<Impl>()) {}

SessionManager::~SessionManager() { shutdown(); }

void SessionManager::start()
{
    if (running_.exchange(true)) {
        return;
    }

    lt::settings_pack settings;
    settings.set_str(lt::settings_pack::listen_interfaces, "0.0.0.0:6881,[::]:6881");
    settings.set_bool(lt::settings_pack::enable_dht, true);
    settings.set_bool(lt::settings_pack::enable_lsd, true);
    settings.set_bool(lt::settings_pack::enable_upnp, true);
    settings.set_bool(lt::settings_pack::enable_natpmp, true);
    impl_->session.apply_settings(settings);

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

} // namespace torrex
