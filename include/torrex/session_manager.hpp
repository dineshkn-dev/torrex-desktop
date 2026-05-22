#pragma once

#include <torrex/types.hpp>

#include <atomic>
#include <memory>
#include <vector>

namespace torrex {

/// Owns the libtorrent session on a dedicated worker thread. No Qt types.
class SessionManager {
public:
    SessionManager();
    ~SessionManager();

    SessionManager(const SessionManager&) = delete;
    SessionManager& operator=(const SessionManager&) = delete;

    void start();
    void shutdown();

    [[nodiscard]] bool is_running() const noexcept { return running_.load(); }

    /// Thread-safe snapshot for UI (may be called from any thread).
    [[nodiscard]] std::vector<TorrentSnapshot> snapshots() const;

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
    std::atomic<bool> running_{false};
};

} // namespace torrex
