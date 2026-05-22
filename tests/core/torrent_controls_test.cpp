#include <torrex/session_manager.hpp>

#include <gtest/gtest.h>

#include <chrono>
#include <thread>

namespace {

TEST(TorrentControls, AsyncTorrentNotFoundForFilePriority) {
    torrex::SessionManager session;
    session.start();
    EXPECT_TRUE(session.set_file_priority("abc", 0, 4).empty());
    std::this_thread::sleep_for(std::chrono::milliseconds(200));
    EXPECT_EQ(session.take_last_error(), "Torrent not found.");
    session.shutdown();
}

TEST(TorrentControls, AsyncTorrentNotFoundForSequential) {
    torrex::SessionManager session;
    session.start();
    EXPECT_TRUE(session.set_sequential_download("abc", true).empty());
    std::this_thread::sleep_for(std::chrono::milliseconds(200));
    EXPECT_EQ(session.take_last_error(), "Torrent not found.");
    session.shutdown();
}

TEST(TorrentControls, RejectsEmptyTorrentId) {
    torrex::SessionManager session;
    session.start();
    EXPECT_EQ(session.set_file_priority("", 0, 4), "Torrent id is empty.");
    EXPECT_EQ(session.set_sequential_download("", true), "Torrent id is empty.");
    session.shutdown();
}

TEST(TorrentControls, RequiresRunningSession) {
    torrex::SessionManager session;
    EXPECT_EQ(session.set_file_priority("abc", 0, 4), "Session is not running.");
    EXPECT_EQ(session.set_sequential_download("abc", true), "Session is not running.");
}

} // namespace
