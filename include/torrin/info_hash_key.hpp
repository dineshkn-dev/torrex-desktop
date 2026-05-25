#pragma once

#include <libtorrent/info_hash.hpp>

#include <string>

namespace torrin {

/// Stable lowercase hex key for maps and QML (40 chars for v1 SHA-1).
[[nodiscard]] std::string info_hash_key(const lt::info_hash_t& hashes);

} // namespace torrin
