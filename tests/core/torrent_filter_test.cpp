#include <torrex/torrent_filter.hpp>
#include <torrex/types.hpp>

#include <gtest/gtest.h>

TEST(TorrentFilter, DownloadingIncludesActiveTransfer)
{
    torrex::TorrentSnapshot snap;
    snap.state = torrex::TorrentState::Downloading;
    snap.progress_percent = 36;
    EXPECT_TRUE(torrex::torrent_matches_filter(snap, "downloading"));
}

TEST(TorrentFilter, DownloadingExcludesCompleteSeed)
{
    torrex::TorrentSnapshot snap;
    snap.state = torrex::TorrentState::Seeding;
    snap.progress_percent = 100;
    EXPECT_FALSE(torrex::torrent_matches_filter(snap, "downloading"));
}

TEST(TorrentFilter, DownloadingIncludesIncompleteSeedingEdgeCase)
{
    torrex::TorrentSnapshot snap;
    snap.state = torrex::TorrentState::Seeding;
    snap.progress_percent = 40;
    EXPECT_TRUE(torrex::torrent_matches_filter(snap, "downloading"));
}
