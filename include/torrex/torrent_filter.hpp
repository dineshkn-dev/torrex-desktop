#pragma once

#include <torrex/types.hpp>

#include <cstring>

namespace torrex {

inline bool is_complete_seeding(const TorrentSnapshot& item)
{
    return item.state == TorrentState::Seeding && item.progress_percent >= 100;
}

inline bool torrent_matches_filter(const TorrentSnapshot& item, const char* filter_id)
{
    if (filter_id == nullptr) {
        return true;
    }
    if (std::strcmp(filter_id, "all") == 0) {
        return true;
    }
    if (std::strcmp(filter_id, "downloading") == 0) {
        if (item.state == TorrentState::Paused || item.state == TorrentState::Error) {
            return false;
        }
        return !is_complete_seeding(item);
    }
    if (std::strcmp(filter_id, "seeding") == 0) {
        return is_complete_seeding(item);
    }
    if (std::strcmp(filter_id, "paused") == 0) {
        return item.state == TorrentState::Paused;
    }
    return true;
}

} // namespace torrex
