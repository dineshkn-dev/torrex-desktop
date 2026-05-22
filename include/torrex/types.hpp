#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace torrex {

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
};

} // namespace torrex
