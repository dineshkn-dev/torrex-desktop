#pragma once

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
};

constexpr int kMinListenPort = 1024;
constexpr int kMaxListenPort = 65535;

} // namespace torrex
