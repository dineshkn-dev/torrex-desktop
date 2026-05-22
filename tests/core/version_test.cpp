#include <torrex/version.hpp>

#include <gtest/gtest.h>

TEST(Version, IsNonEmpty) {
    EXPECT_STREQ(torrex::kVersion, "0.1.0");
    EXPECT_NE(torrex::kName, nullptr);
}
