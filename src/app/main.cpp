#include "app_controller.hpp"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QFile>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QStyleHints>

namespace {

void add_plugin_path(const QString& path)
{
    if (path.isEmpty() || !QDir(path).exists()) {
        return;
    }
    QCoreApplication::addLibraryPath(path);
}

void add_bundle_plugin_paths()
{
    const QDir macos_dir(QCoreApplication::applicationDirPath());
    const QString plugins_dir = macos_dir.absoluteFilePath(QStringLiteral("../PlugIns"));
    add_plugin_path(plugins_dir);
    add_plugin_path(plugins_dir + QStringLiteral("/imageformats"));
    add_plugin_path(plugins_dir + QStringLiteral("/platforms"));
}

void add_vcpkg_qt_plugin_paths()
{
    add_bundle_plugin_paths();

    const QFileInfo exe(QCoreApplication::applicationFilePath());
    const QDir bin_dir = exe.absoluteDir();

    const QStringList plugin_roots = {
#ifdef TORREX_QT_PLUGINS_DIR
        QStringLiteral(TORREX_QT_PLUGINS_DIR),
#endif
        bin_dir.absoluteFilePath(QStringLiteral("../vcpkg_installed/arm64-osx/Qt6/plugins")),
        bin_dir.absoluteFilePath(QStringLiteral("../vcpkg_installed/x64-osx/Qt6/plugins")),
        bin_dir.absoluteFilePath(QStringLiteral("../../vcpkg_installed/arm64-osx/Qt6/plugins")),
        bin_dir.absoluteFilePath(QStringLiteral("../../vcpkg_installed/x64-osx/Qt6/plugins")),
        // Legacy layout (no Qt6 subdir)
        bin_dir.absoluteFilePath(QStringLiteral("../vcpkg_installed/arm64-osx/plugins")),
        bin_dir.absoluteFilePath(QStringLiteral("../../vcpkg_installed/arm64-osx/plugins")),
    };

    for (const QString& root : plugin_roots) {
        add_plugin_path(root);
        add_plugin_path(root + QStringLiteral("/imageformats"));
        add_plugin_path(root + QStringLiteral("/platforms"));
    }
}

} // namespace

int main(int argc, char* argv[])
{
    // Before QGuiApplication / QML: use Basic style; PNG plugin must be available for any
    // remaining built-in control icons (see vcpkg qtbase "png" feature).
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("Torrex");
    QGuiApplication::setOrganizationName("Torrex");
    QGuiApplication::setApplicationVersion("0.1.0");

    if (QFile::exists(QStringLiteral(":/brand/torrex-mark.svg"))) {
        QGuiApplication::setWindowIcon(QIcon(QStringLiteral(":/brand/torrex-mark.svg")));
    }

    add_vcpkg_qt_plugin_paths();

    QGuiApplication::styleHints()->setColorScheme(Qt::ColorScheme::Unknown);

    torrex::app::AppController controller;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appController", &controller);
    engine.rootContext()->setContextProperty(QStringLiteral("torrexUiRev"), 2);
    engine.loadFromModule("Torrex", "Main");

    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    return app.exec();
}
