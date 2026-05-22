#include "app_controller.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QStyleHints>

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("Torrex");
    QGuiApplication::setOrganizationName("Torrex");
    QGuiApplication::setApplicationVersion("0.1.0");

    // Default: match OS appearance (Light / Dark / Auto). Do not force a scheme here.
    QGuiApplication::styleHints()->setColorScheme(Qt::ColorScheme::Unknown);

    // Fusion respects system light/dark via styleHints and allows themed panels/menus.
    // (macOS native Quick style rejects custom control backgrounds and can break menus.)
    QQuickStyle::setStyle(QStringLiteral("Fusion"));

    torrex::app::AppController controller;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appController", &controller);
    engine.loadFromModule("Torrex", "Main");

    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    return app.exec();
}
