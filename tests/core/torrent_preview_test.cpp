#include <torrin/torrent_preview.hpp>

#include <gtest/gtest.h>

#include <filesystem>

TEST(TorrentPreview, RejectsMissingTorrentFile) {
    torrin::TorrentAddPreview preview;
    const std::string err =
        torrin::preview_torrent_file("/nonexistent/torrin-missing.torrent", preview);
    EXPECT_FALSE(err.empty());
    EXPECT_TRUE(preview.files.empty());
}

TEST(TorrentPreview, RejectsInvalidMagnet) {
    torrin::TorrentAddPreview preview;
    const std::string err = torrin::preview_magnet_uri("not-a-magnet", preview);
    EXPECT_FALSE(err.empty());
}

TEST(TorrentPreview, ParsesMagnetDisplayName) {
    torrin::TorrentAddPreview preview;
    const std::string err = torrin::preview_magnet_uri(
        "magnet:?xt=urn:btih:0123456789abcdef0123456789abcdef01234567&dn=Example", preview);
    ASSERT_TRUE(err.empty());
    EXPECT_EQ(preview.name, "Example");
    EXPECT_FALSE(preview.info_hash_hex.empty());
}
