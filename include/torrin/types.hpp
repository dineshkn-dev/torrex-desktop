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
    std::string save_path;
    bool sequential_download = false;
    std::vector<TorrentFileSnapshot> files;
};

} // namespace torrin
