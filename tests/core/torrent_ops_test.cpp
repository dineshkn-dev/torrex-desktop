#include <torrin/session_manager.hpp>

#include <gtest/gtest.h>

namespace {

TEST(TorrentOpsValidation, RejectsEmptyIdWhenRunning)
{
    torrin::SessionManager session;
    session.start();
    EXPECT_EQ(session.pause_torrent(""), "Torrent id is empty.");
    EXPECT_EQ(session.resume_torrent(""), "Torrent id is empty.");
    EXPECT_EQ(session.stop_seeding(""), "Torrent id is empty.");
    EXPECT_EQ(session.resume_seeding(""), "Torrent id is empty.");
    EXPECT_EQ(session.force_recheck(""), "Torrent id is empty.");
    EXPECT_EQ(session.force_reannounce(""), "Torrent id is empty.");
    EXPECT_EQ(session.remove_torrent(""), "Torrent id is empty.");
    session.shutdown();
}

TEST(TorrentOpsValidation, RequiresRunningSession)
{
    torrin::SessionManager session;
    EXPECT_EQ(session.pause_torrent("abc"), "Session is not running.");
    EXPECT_EQ(session.stop_seeding("abc"), "Session is not running.");
    EXPECT_EQ(session.resume_seeding("abc"), "Session is not running.");
    EXPECT_EQ(session.force_recheck("abc"), "Session is not running.");
    EXPECT_EQ(session.force_reannounce("abc"), "Session is not running.");
}

} // namespace
