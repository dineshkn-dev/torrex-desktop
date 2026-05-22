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

    QQuickStyle::setStyle("Fusion");

    // Follow macOS Settings → Appearance (Light / Dark / Auto).
    // Theme.qml reads Qt.application.colorScheme for window colors.
    QGuiApplication::styleHints()->setColorScheme(Qt::ColorScheme::Unknown);

    torrex::app::AppController controller;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appController", &controller);
    engine.loadFromModule("Torrex", "Main");

    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    return app.exec();
}
