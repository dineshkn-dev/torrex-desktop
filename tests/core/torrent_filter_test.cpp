#include <torrin/torrent_filter.hpp>
#include <torrin/types.hpp>

#include <gtest/gtest.h>

TEST(TorrentFilter, DownloadingIncludesActiveTransfer)
{
    torrin::TorrentSnapshot snap;
    snap.state = torrin::TorrentState::Downloading;
    snap.progress_percent = 36;
    EXPECT_TRUE(torrin::torrent_matches_filter(snap, "downloading"));
}

TEST(TorrentFilter, DownloadingExcludesCompleteSeed)
{
    torrin::TorrentSnapshot snap;
    snap.state = torrin::TorrentState::Seeding;
    snap.progress_percent = 100;
    EXPECT_FALSE(torrin::torrent_matches_filter(snap, "downloading"));
}

TEST(TorrentFilter, DownloadingIncludesIncompleteSeedingEdgeCase)
{
    torrin::TorrentSnapshot snap;
    snap.state = torrin::TorrentState::Seeding;
    snap.progress_percent = 40;
    EXPECT_TRUE(torrin::torrent_matches_filter(snap, "downloading"));
}
