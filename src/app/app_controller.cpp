#include "app_controller.hpp"

#include <torrex/version.hpp>

namespace torrex::app {

AppController::AppController(QObject* parent)
    : QObject(parent), torrent_model_(session_, this)
{
    session_.start();
}

AppController::~AppController() { session_.shutdown(); }

QString AppController::version() const { return QString::fromUtf8(torrex::kVersion); }

void AppController::refreshTorrents() { torrent_model_.refresh(); }

} // namespace torrex::app
