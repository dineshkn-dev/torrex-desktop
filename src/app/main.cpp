#include "app_controller.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("Torrex");
    QGuiApplication::setOrganizationName("Torrex");
    QGuiApplication::setApplicationVersion("0.1.0");

    QQuickStyle::setStyle("Fusion");

    torrex::app::AppController controller;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appController", &controller);
    engine.loadFromModule("Torrex", "Main");

    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    return app.exec();
}
