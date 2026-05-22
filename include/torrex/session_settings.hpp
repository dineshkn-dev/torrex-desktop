#pragma once

#include <string>

namespace torrex {

/// Engine session/network limits (no Qt). Rates are bytes/s; 0 means unlimited.
struct SessionSettings {
    int download_rate_limit = 0;
    int upload_rate_limit = 0;
    int listen_port = 6881;
    bool enable_upnp = true;
    bool enable_natpmp = true;
    bool enable_dht = true;
    bool enable_lsd = true;

    /// 0 = none, 1 = SOCKS5, 2 = HTTP (mapped to libtorrent in session_manager).
    int proxy_type = 0;
    std::string proxy_host;
    int proxy_port = 1080;
    std::string proxy_username;
    std::string proxy_password;
    bool proxy_peer_connections = true;
    bool proxy_tracker_connections = true;
};

constexpr int kMinListenPort = 1024;
constexpr int kMaxListenPort = 65535;

constexpr int kProxyTypeNone = 0;
constexpr int kProxyTypeSocks5 = 1;
constexpr int kProxyTypeHttp = 2;

} // namespace torrex
