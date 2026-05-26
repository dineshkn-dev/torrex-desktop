#pragma once

#include <QString>

namespace torrin::app {

[[nodiscard]] bool screenshotMode();

[[nodiscard]] QString screenshotSessionDirectory();

[[nodiscard]] QString screenshotDownloadDirectory();

[[nodiscard]] QString redactUserPath(QString path);

void seedScreenshotDemoTorrents(class AppController& controller);

} // namespace torrin::app
