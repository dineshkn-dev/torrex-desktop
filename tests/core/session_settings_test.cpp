#include <torrin/session_manager.hpp>
#include <torrin/session_settings.hpp>

#include <gtest/gtest.h>

#include <filesystem>

namespace {

std::filesystem::path temp_session_dir()
{
    const auto base = std::filesystem::temp_directory_path() / "torrin_test_session";
    std::error_code ec;
    std::filesystem::remove_all(base, ec);
    std::filesystem::create_directories(base, ec);
    return base;
}

} // namespace

TEST(SessionSettings, ClampInvalidPort) {
    torrin::SessionManager session;
    torrin::SessionSettings settings;
    settings.listen_port = 80;
    session.set_session_settings(settings);
    EXPECT_EQ(session.session_settings().listen_port, 6881);
}

TEST(SessionSettings, ApplyAndReadBack) {
    torrin::SessionManager session;
    torrin::SessionSettings settings;
    settings.download_rate_limit = 8192;
    settings.upload_rate_limit = 4096;
    settings.listen_port = 7890;
    settings.enable_upnp = false;
    session.set_session_settings(settings);

    const torrin::SessionSettings stored = session.session_settings();
    EXPECT_EQ(stored.download_rate_limit, 8192);
    EXPECT_EQ(stored.upload_rate_limit, 4096);
    EXPECT_EQ(stored.listen_port, 7890);
    EXPECT_FALSE(stored.enable_upnp);
}

TEST(SessionSettings, ProxySettingsRoundTrip) {
    torrin::SessionManager session;
    torrin::SessionSettings settings;
    settings.proxy_type = torrin::kProxyTypeSocks5;
    settings.proxy_host = "127.0.0.1";
    settings.proxy_port = 9050;
    session.set_session_settings(settings);

    const torrin::SessionSettings stored = session.session_settings();
    EXPECT_EQ(stored.proxy_type, torrin::kProxyTypeSocks5);
    EXPECT_EQ(stored.proxy_host, "127.0.0.1");
    EXPECT_EQ(stored.proxy_port, 9050);
}

TEST(SessionSettings, PersistSessionStateFile) {
    const std::filesystem::path dir = temp_session_dir();
    {
        torrin::SessionManager session(dir.string());
        session.start();
        session.shutdown();
    }
    EXPECT_TRUE(std::filesystem::is_regular_file(dir / "session.dat"));
}
