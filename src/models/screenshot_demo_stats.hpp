#pragma once

#include <torrin/types.hpp>

#include <vector>

namespace torrin::models {

/// When `TORRIN_SCREENSHOT` is set, fill plausible transfer stats for README captures.
void applyScreenshotDemoStats(std::vector<TorrentSnapshot>& items);

} // namespace torrin::models
