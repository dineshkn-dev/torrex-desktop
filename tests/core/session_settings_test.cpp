#include <torrex/session_manager.hpp>
#include <torrex/session_settings.hpp>

#include <gtest/gtest.h>

#include <filesystem>

namespace {

std::filesystem::path temp_session_dir()
{
    const auto base = std::filesystem::temp_directory_path() / "torrex_test_session";
    std::error_code ec;
    std::filesystem::remove_all(base, ec);
    std::filesystem::create_directories(base, ec);
    return base;
}

} // namespace

TEST(SessionSettings, ClampInvalidPort) {
    torrex::SessionManager session;
    torrex::SessionSettings settings;
    settings.listen_port = 80;
    session.set_session_settings(settings);
    EXPECT_EQ(session.session_settings().listen_port, 6881);
}

TEST(SessionSettings, ApplyAndReadBack) {
    torrex::SessionManager session;
    torrex::SessionSettings settings;
    settings.download_rate_limit = 8192;
    settings.upload_rate_limit = 4096;
    settings.listen_port = 7890;
    settings.enable_upnp = false;
    session.set_session_settings(settings);

    const torrex::SessionSettings stored = session.session_settings();
    EXPECT_EQ(stored.download_rate_limit, 8192);
    EXPECT_EQ(stored.upload_rate_limit, 4096);
    EXPECT_EQ(stored.listen_port, 7890);
    EXPECT_FALSE(stored.enable_upnp);
}

TEST(SessionSettings, PersistSessionStateFile) {
    const std::filesystem::path dir = temp_session_dir();
    {
        torrex::SessionManager session(dir.string());
        session.start();
        session.shutdown();
    }
    EXPECT_TRUE(std::filesystem::is_regular_file(dir / "session.dat"));
}
