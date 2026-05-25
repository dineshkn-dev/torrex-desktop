#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace torrin {

struct TorrentPreviewFile {
    int index = 0;
    std::string path;
    std::int64_t size = 0;
};

struct TorrentAddPreview {
    std::string name;
    std::string info_hash_hex;
    std::int64_t total_size = 0;
    std::vector<TorrentPreviewFile> files;
};

/// Parse a `.torrent` file without starting a download. Empty string on success.
[[nodiscard]] std::string preview_torrent_file(const std::string& path, TorrentAddPreview& out);

/// Parse magnet URI (name from `dn` when present; files empty until metadata).
[[nodiscard]] std::string preview_magnet_uri(const std::string& uri, TorrentAddPreview& out);

} // namespace torrin
