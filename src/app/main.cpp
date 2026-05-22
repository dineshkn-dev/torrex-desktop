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

void add_bundle_plugin_paths()
{
    const QDir macos_dir(QCoreApplication::applicationDirPath());
    const QString plugins_dir = macos_dir.absoluteFilePath(QStringLiteral("../PlugIns"));
    if (QDir(plugins_dir).exists()) {
        QCoreApplication::addLibraryPath(plugins_dir);
        const QString imageformats = plugins_dir + QStringLiteral("/imageformats");
        if (QDir(imageformats).exists()) {
            QCoreApplication::addLibraryPath(imageformats);
        }
    }
}

void add_vcpkg_qt_plugin_paths()
{
    add_bundle_plugin_paths();

    const QFileInfo exe(QCoreApplication::applicationFilePath());
    const QDir bin_dir = exe.absoluteDir();
    const QStringList candidates = {
        bin_dir.absoluteFilePath(QStringLiteral("../vcpkg_installed/arm64-osx/plugins")),
        bin_dir.absoluteFilePath(QStringLiteral("../vcpkg_installed/x64-osx/plugins")),
        bin_dir.absoluteFilePath(QStringLiteral("../../vcpkg_installed/arm64-osx/plugins")),
    };
    for (const QString& path : candidates) {
        if (!QDir(path).exists()) {
            continue;
        }
        QCoreApplication::addLibraryPath(path);
        const QString imageformats = path + QStringLiteral("/imageformats");
        if (QDir(imageformats).exists()) {
            QCoreApplication::addLibraryPath(imageformats);
        }
    }
}

} // namespace

int main(int argc, char* argv[])
{
    // Before QGuiApplication / QML: Fusion style PNG assets fail on some macOS/Qt builds.
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("Torrex");
    QGuiApplication::setOrganizationName("Torrex");
    QGuiApplication::setApplicationVersion("0.1.0");

    add_vcpkg_qt_plugin_paths();

    // Default: match OS appearance (Light / Dark / Auto). Do not force a scheme here.
    QGuiApplication::styleHints()->setColorScheme(Qt::ColorScheme::Unknown);

    torrex::app::AppController controller;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appController", &controller);
    engine.rootContext()->setContextProperty(
        QStringLiteral("torrexUiRev"),
        2); // bump when QML layout changes; visible in window title
    engine.loadFromModule("Torrex", "Main");

    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    return app.exec();
}
