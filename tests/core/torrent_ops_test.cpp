#include <torrex/session_manager.hpp>

#include <gtest/gtest.h>

namespace {

TEST(TorrentOpsValidation, RejectsEmptyIdWhenRunning)
{
    torrex::SessionManager session;
    session.start();
    EXPECT_EQ(session.pause_torrent(""), "Torrent id is empty.");
    EXPECT_EQ(session.resume_torrent(""), "Torrent id is empty.");
    EXPECT_EQ(session.remove_torrent(""), "Torrent id is empty.");
    session.shutdown();
}

TEST(TorrentOpsValidation, RequiresRunningSession)
{
    torrex::SessionManager session;
    EXPECT_EQ(session.pause_torrent("abc"), "Session is not running.");
}

} // namespace
