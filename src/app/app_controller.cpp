#include "app_controller.hpp"

#include <torrex/version.hpp>

#include <QUrl>

namespace torrex::app {

AppController::AppController(QObject* parent)
    : QObject(parent), torrent_model_(session_, this)
{
    session_.start();
    setStatusMessage(tr("Engine running — add a torrent to begin (download support coming next)."));
}

AppController::~AppController() { session_.shutdown(); }

QString AppController::version() const { return QString::fromUtf8(torrex::kVersion); }

void AppController::refreshTorrents()
{
    torrent_model_.refresh();
    setStatusMessage(tr("Refreshed — %1 torrent(s)").arg(torrent_model_.rowCount()));
}

void AppController::addMagnetUri(const QString& uri)
{
    const QString trimmed = uri.trimmed();
    if (trimmed.isEmpty()) {
        setStatusMessage(tr("Magnet URI is empty."));
        return;
    }
    if (!trimmed.startsWith(QStringLiteral("magnet:?"), Qt::CaseInsensitive)) {
        setStatusMessage(tr("Invalid magnet link — must start with magnet:?"));
        return;
    }
    // Phase 1: wire to SessionManager::addTorrent
    setStatusMessage(tr("Magnet accepted (not queued yet): %1…").arg(trimmed.left(48)));
}

void AppController::addTorrentFile(const QUrl& file_url)
{
    if (!file_url.isLocalFile()) {
        setStatusMessage(tr("Could not open torrent file."));
        return;
    }
    const QString path = file_url.toLocalFile();
    if (!path.endsWith(QStringLiteral(".torrent"), Qt::CaseInsensitive)) {
        setStatusMessage(tr("Please choose a .torrent file."));
        return;
    }
    setStatusMessage(tr("Torrent file selected (not queued yet): %1").arg(path));
}

void AppController::setStatusMessage(const QString& message)
{
    if (status_message_ == message) {
        return;
    }
    status_message_ = message;
    emit statusMessageChanged();
}

} // namespace torrex::app
