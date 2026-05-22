#include "app_controller.hpp"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QStyleHints>

namespace {

void add_vcpkg_qt_plugin_paths()
{
    const QFileInfo exe(QCoreApplication::applicationFilePath());
    const QDir bin_dir = exe.absoluteDir();
    const QStringList candidates = {
        bin_dir.absoluteFilePath(QStringLiteral("../vcpkg_installed/arm64-osx/plugins")),
        bin_dir.absoluteFilePath(QStringLiteral("../vcpkg_installed/x64-osx/plugins")),
        bin_dir.absoluteFilePath(QStringLiteral("../../vcpkg_installed/arm64-osx/plugins")),
    };
    for (const QString& path : candidates) {
        if (QDir(path).exists()) {
            QCoreApplication::addLibraryPath(path);
        }
    }
}

} // namespace

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("Torrex");
    QGuiApplication::setOrganizationName("Torrex");
    QGuiApplication::setApplicationVersion("0.1.0");

    add_vcpkg_qt_plugin_paths();

    // Default: match OS appearance (Light / Dark / Auto). Do not force a scheme here.
    QGuiApplication::styleHints()->setColorScheme(Qt::ColorScheme::Unknown);

    // Basic: vector-friendly controls without Fusion PNG assets (broken on some macOS/Qt builds).
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    torrex::app::AppController controller;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appController", &controller);
    engine.loadFromModule("Torrex", "Main");

    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    return app.exec();
}
