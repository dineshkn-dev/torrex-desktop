#pragma once

#include <torrex/session_manager.hpp>

#include "torrent_list_model.hpp"

#include <QObject>
#include <memory>

namespace torrex::app {

class AppController : public QObject {
    Q_OBJECT
    Q_PROPERTY(models::TorrentListModel* torrents READ torrents CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)

public:
    explicit AppController(QObject* parent = nullptr);
    ~AppController() override;

    models::TorrentListModel* torrents() { return &torrent_model_; }
    QString version() const;

    Q_INVOKABLE void refreshTorrents();
    Q_INVOKABLE void addMagnetUri(const QString& uri);
    Q_INVOKABLE void addTorrentFile(const QUrl& file_url);

    [[nodiscard]] QString statusMessage() const { return status_message_; }

signals:
    void statusMessageChanged();

private:
    void setStatusMessage(const QString& message);

    QString status_message_ = QStringLiteral("Ready");
    SessionManager session_;
    models::TorrentListModel torrent_model_;
};

} // namespace torrex::app
