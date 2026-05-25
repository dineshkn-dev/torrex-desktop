#include <torrin/session_manager.hpp>

#include <gtest/gtest.h>

TEST(AddTorrentValidation, RejectsInvalidMagnet) {
    torrin::SessionManager session;
    session.start();
    const std::string err = session.add_magnet("not-a-magnet", "/tmp/torrin-test");
    EXPECT_FALSE(err.empty());
    session.shutdown();
}

TEST(AddTorrentValidation, RejectsMissingFile) {
    torrin::SessionManager session;
    session.start();
    const std::string err =
        session.add_torrent_file("/nonexistent/torrin-missing.torrent", "/tmp/torrin-test");
    EXPECT_FALSE(err.empty());
    session.shutdown();
}
