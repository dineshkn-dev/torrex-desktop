#include "screenshot_mode.hpp"

#include "app_controller.hpp"

#include <QDir>
#include <QTimer>

namespace torrin::app {

namespace {

constexpr auto kScreenshotEnv = "TORRIN_SCREENSHOT";

} // namespace

bool screenshotMode()
{
    return qEnvironmentVariableIsSet(kScreenshotEnv);
}

QString screenshotSessionDirectory()
{
    return QDir::temp().absoluteFilePath(QStringLiteral("torrin-screenshot-session"));
}

QString screenshotDownloadDirectory()
{
    return QStringLiteral("/Users/Shared/Torrin/Downloads");
}

QString redactUserPath(QString path)
{
    // Screenshot runs use /Users/Shared/Torrin/... already; do not rewrite /Users/Shared.
    if (!screenshotMode() || path.isEmpty()) {
        return path;
    }
    return path;
}

void seedScreenshotDemoTorrents(AppController& controller)
{
    if (!screenshotMode()) {
        return;
    }

    const QStringList magnets{
        QStringLiteral(
            "magnet:?xt=urn:btih:9FC20B9E98FA57B3447A3D1AC6DED51405881606"
            "&dn=ubuntu-24.04.1-desktop-amd64.iso"),
        QStringLiteral(
            "magnet:?xt=urn:btih:ffb28d848f241108bfffabfabc988ed34715f7c"
            "&dn=debian-live-12.8.0-amd64-gnome.iso"),
    };

    QTimer::singleShot(1500, &controller, [&controller, magnets]() {
        for (int i = 0; i < magnets.size(); ++i) {
            const QString& uri = magnets.at(i);
            QTimer::singleShot(i * 400, &controller, [&controller, uri]() {
                controller.addMagnetUri(uri, screenshotDownloadDirectory());
            });
        }
    });
}

} // namespace torrin::app
