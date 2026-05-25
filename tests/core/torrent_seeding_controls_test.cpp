#include <torrin/torrent_filter.hpp>
#include <torrin/types.hpp>

#include <gtest/gtest.h>

TEST(TorrentSeedingControls, StopSeedingRequiresCompleteSeed) {
    torrin::TorrentSnapshot snap;
    snap.state = torrin::TorrentState::Seeding;
    snap.progress_percent = 100;
    EXPECT_TRUE(torrin::is_complete_seeding(snap));

    snap.progress_percent = 80;
    EXPECT_FALSE(torrin::is_complete_seeding(snap));

    snap.progress_percent = 100;
    snap.state = torrin::TorrentState::Downloading;
    EXPECT_FALSE(torrin::is_complete_seeding(snap));
}
