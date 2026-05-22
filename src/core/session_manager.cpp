#include <torrex/session_manager.hpp>

#include <libtorrent/session.hpp>
#include <libtorrent/settings_pack.hpp>

#include <mutex>
#include <thread>

namespace torrex {

struct SessionManager::Impl {
    lt::session session{lt::session_params{}};
    mutable std::mutex mutex;
    std::thread worker;
    std::atomic<bool> stop{false};
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
            std::vector<lt::alert*> alerts;
            impl_->session.pop_alerts(&alerts);
            for (lt::alert* alert : alerts) {
                (void)alert;
                // Phase 1: dispatch to TorrentManager / update snapshots
            }
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
    return {};
}

} // namespace torrex
