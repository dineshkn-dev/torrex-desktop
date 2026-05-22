#include <torrex/torrent_preview.hpp>

#include <libtorrent/load_torrent.hpp>
#include <libtorrent/magnet_uri.hpp>
#include <libtorrent/torrent_info.hpp>

#include <filesystem>
#include <sstream>

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

void fill_from_torrent_info(const lt::torrent_info& info, TorrentAddPreview& out)
{
    out.name = info.name();
    if (out.name.empty()) {
        out.name = "Torrent";
    }
    out.info_hash_hex = hash_key(info.info_hashes());
    out.files.clear();
    out.total_size = 0;

    const lt::file_storage& storage = info.files();
    out.files.reserve(static_cast<std::size_t>(storage.num_files()));
    for (lt::file_index_t i : storage.file_range()) {
        TorrentPreviewFile file;
        file.index = static_cast<int>(i);
        file.path = storage.file_path(i);
        file.size = storage.file_size(i);
        out.total_size += file.size;
        out.files.push_back(std::move(file));
    }
}

} // namespace

std::string preview_torrent_file(const std::string& path, TorrentAddPreview& out)
{
    out = {};
    if (!std::filesystem::is_regular_file(path)) {
        return "Torrent file not found.";
    }

    try {
        const lt::add_torrent_params params = lt::load_torrent_file(path);
        const std::shared_ptr<const lt::torrent_info> info = params.ti;
        if (!info) {
            return "Invalid torrent file.";
        }
        fill_from_torrent_info(*info, out);
        return {};
    } catch (const std::exception& ex) {
        return std::string("Invalid torrent file: ") + ex.what();
    }
}

std::string preview_magnet_uri(const std::string& uri, TorrentAddPreview& out)
{
    out = {};
    lt::error_code ec;
    const lt::add_torrent_params params = lt::parse_magnet_uri(uri, ec);
    if (ec) {
        return "Invalid magnet URI: " + ec.message();
    }

    out.info_hash_hex = hash_key(params.info_hashes);
    out.name = params.name;
    if (out.name.empty()) {
        out.name = "Magnet link";
    }
    if (params.ti) {
        fill_from_torrent_info(*params.ti, out);
    }
    return {};
}

} // namespace torrex
