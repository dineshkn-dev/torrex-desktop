#include <torrin/version.hpp>

#include <gtest/gtest.h>

TEST(Version, IsNonEmpty) {
    EXPECT_STREQ(torrin::kVersion, "1.0.0");
    EXPECT_STREQ(torrin::kName, "Torrin");
}
