#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace torrin {

struct InfoHash {
    std::string v1_hex; // 40-char hex when available
};

enum class TorrentState {
    Idle,
    Checking,
    Downloading,
    Seeding,
    Paused,
    Error,
};

struct TorrentFileSnapshot {
    int index = 0;
    std::string path;
    int priority = 4; // libtorrent download_priority_t (0 = do not download)
    int progress_percent = 0;
    std::int64_t size_bytes = 0;
};

struct TorrentSnapshot {
    InfoHash info_hash;
    std::string name;
    TorrentState state = TorrentState::Idle;
    std::int64_t downloaded = 0;
    std::int64_t total = 0;
    int progress_percent = 0;
    std::int64_t download_rate = 0;
    std::int64_t upload_rate = 0;
    std::int64_t uploaded_total = 0;
    int num_peers = 0;
    int num_seeds = 0;
    int num_connections = 0;
    /// Seconds until complete; -1 if unknown.
    int eta_seconds = -1;
    bool has_metadata = false;
    std::string save_path;
    /// True when a completed torrent has upload disabled via stop-seeding (not paused).
    bool upload_stopped = false;
    bool sequential_download = false;
    /// Unix seconds when the torrent was added to the session (libtorrent added_time).
    std::int64_t added_time = 0;
    std::vector<TorrentFileSnapshot> files;
};

} // namespace torrin
