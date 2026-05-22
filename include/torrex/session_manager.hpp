#pragma once

#include <torrex/types.hpp>

#include <atomic>
#include <memory>
#include <string>
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

    /// Enqueues add; returns empty string on success, otherwise an error message.
    [[nodiscard]] std::string add_magnet(const std::string& uri, const std::string& save_path);
    [[nodiscard]] std::string add_torrent_file(const std::string& path,
                                               const std::string& save_path);

    /// Last engine error (e.g. failed add); cleared when read.
    [[nodiscard]] std::string take_last_error();

    /// `info_hash_hex` is the key from `TorrentSnapshot::info_hash.v1_hex`.
    [[nodiscard]] std::string pause_torrent(const std::string& info_hash_hex);
    [[nodiscard]] std::string resume_torrent(const std::string& info_hash_hex);
    [[nodiscard]] std::string remove_torrent(const std::string& info_hash_hex,
                                             bool delete_files = false);

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
    std::atomic<bool> running_{false};
};

} // namespace torrex
