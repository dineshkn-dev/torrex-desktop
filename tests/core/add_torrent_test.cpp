#include <torrex/session_manager.hpp>

#include <gtest/gtest.h>

TEST(AddTorrentValidation, RejectsInvalidMagnet) {
    torrex::SessionManager session;
    session.start();
    const std::string err = session.add_magnet("not-a-magnet", "/tmp/torrex-test");
    EXPECT_FALSE(err.empty());
    session.shutdown();
}

TEST(AddTorrentValidation, RejectsMissingFile) {
    torrex::SessionManager session;
    session.start();
    const std::string err =
        session.add_torrent_file("/nonexistent/torrex-missing.torrent", "/tmp/torrex-test");
    EXPECT_FALSE(err.empty());
    session.shutdown();
}
