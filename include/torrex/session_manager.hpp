#pragma once

#include <torrex/session_settings.hpp>
#include <torrex/torrent_preview.hpp>
#include <torrex/types.hpp>

#include <atomic>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include <vector>

namespace torrex {

/// Owns the libtorrent session on a dedicated worker thread. No Qt types.
class SessionManager {
public:
    /// `data_directory` stores `session.dat` and `torrents/*.resume` for fast-resume.
    explicit SessionManager(std::string data_directory = {});
    ~SessionManager();

    SessionManager(const SessionManager&) = delete;
    SessionManager& operator=(const SessionManager&) = delete;

    void start();
    void shutdown();

    [[nodiscard]] bool is_running() const noexcept { return running_.load(); }

    void set_session_settings(SessionSettings settings);
    [[nodiscard]] SessionSettings session_settings() const;

    [[nodiscard]] const std::string& data_directory() const noexcept;

    /// Thread-safe snapshot for UI (may be called from any thread).
    [[nodiscard]] std::vector<TorrentSnapshot> snapshots() const;

    /// Enqueues add; returns empty string on success, otherwise an error message.
    [[nodiscard]] std::string add_magnet(
        const std::string& uri, const std::string& save_path,
        const std::vector<std::pair<int, int>>& file_priorities = {});
    [[nodiscard]] std::string add_torrent_file(
        const std::string& path, const std::string& save_path,
        const std::vector<std::pair<int, int>>& file_priorities = {});

    /// Stage a magnet for metadata + file list (hidden from snapshots() until finalized).
    [[nodiscard]] std::string begin_magnet_preview(const std::string& uri,
                                                   const std::string& save_path,
                                                   std::string& out_info_hash_hex);
    [[nodiscard]] std::optional<TorrentAddPreview> magnet_preview(
        const std::string& info_hash_hex) const;
    [[nodiscard]] std::string finalize_magnet_preview(
        const std::string& info_hash_hex,
        const std::vector<std::pair<int, int>>& file_priorities);
    [[nodiscard]] std::string cancel_magnet_preview(const std::string& info_hash_hex);

    /// Last engine error (e.g. failed add); cleared when read.
    [[nodiscard]] std::string take_last_error();
    void clear_last_error();

    /// `info_hash_hex` is the key from `TorrentSnapshot::info_hash.v1_hex`.
    [[nodiscard]] std::string pause_torrent(const std::string& info_hash_hex);
    [[nodiscard]] std::string resume_torrent(const std::string& info_hash_hex);
    [[nodiscard]] std::string remove_torrent(const std::string& info_hash_hex,
                                             bool delete_files = false);

    [[nodiscard]] std::string set_file_priority(const std::string& info_hash_hex,
                                                int file_index,
                                                int priority);
    [[nodiscard]] std::string set_sequential_download(const std::string& info_hash_hex,
                                                      bool enabled);

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
    std::atomic<bool> running_{false};
};

} // namespace torrex
