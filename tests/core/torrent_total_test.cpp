#include <torrin/types.hpp>

#include <gtest/gtest.h>

namespace {

std::int64_t total_from_files(const std::vector<torrin::TorrentFileSnapshot>& files)
{
    std::int64_t sum = 0;
    for (const auto& file : files) {
        sum += file.size_bytes;
    }
    return sum;
}

std::int64_t resolve_total(const std::int64_t st_total,
                           const std::int64_t total_wanted,
                           const std::int64_t total_wanted_done,
                           const float progress,
                           const std::int64_t total_done,
                           const std::vector<torrin::TorrentFileSnapshot>& files)
{
    if (st_total > 0) {
        return st_total;
    }
    if (total_wanted > 0) {
        return total_wanted;
    }
    if (total_wanted_done > 0) {
        return total_wanted_done;
    }
    const std::int64_t from_files = total_from_files(files);
    if (from_files > 0) {
        return from_files;
    }
    if (progress > 0.001F && total_done > 0) {
        return static_cast<std::int64_t>(static_cast<double>(total_done) / progress + 0.5);
    }
    return 0;
}

TEST(TorrentTotal, PrefersFullTorrentTotal)
{
    EXPECT_EQ(resolve_total(2'500'000'000, 0, 353'000'000, 0.14F, 353'000'000, {}),
              2'500'000'000);
}

TEST(TorrentTotal, FallsBackToFileSum)
{
    torrin::TorrentFileSnapshot a;
    a.size_bytes = 1'000'000;
    torrin::TorrentFileSnapshot b;
    b.size_bytes = 500'000;
    EXPECT_EQ(resolve_total(0, 0, 0, 0.F, 0, {a, b}), 1'500'000);
}

TEST(TorrentTotal, DerivesFromProgressWhenNeeded)
{
    const std::int64_t derived = resolve_total(0, 0, 0, 0.14F, 353'000'000, {});
    EXPECT_GT(derived, 2'500'000'000);
    EXPECT_LT(derived, 2'600'000'000);
}

} // namespace
