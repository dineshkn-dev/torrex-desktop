#include <torrex/info_hash_key.hpp>

#include <libtorrent/hex.hpp>

#include <cctype>

namespace torrex {

std::string info_hash_key(const lt::info_hash_t& hashes)
{
    std::string key;
    if (hashes.has_v1()) {
        key = lt::aux::to_hex(lt::span(hashes.v1.data(), lt::sha1_hash::size()));
    } else if (hashes.has_v2()) {
        key = lt::aux::to_hex(lt::span(hashes.v2.data(), lt::sha256_hash::size()));
    }
    for (char& ch : key) {
        ch = static_cast<char>(std::tolower(static_cast<unsigned char>(ch)));
    }
    return key;
}

} // namespace torrex
