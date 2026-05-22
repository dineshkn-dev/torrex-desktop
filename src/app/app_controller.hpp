#pragma once

#include <torrex/session_manager.hpp>

#include <models/torrent_list_model.hpp>

#include <QObject>
#include <memory>

namespace torrex::app {

class AppController : public QObject {
    Q_OBJECT
    Q_PROPERTY(models::TorrentListModel* torrents READ torrents CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)

public:
    explicit AppController(QObject* parent = nullptr);
    ~AppController() override;

    models::TorrentListModel* torrents() { return &torrent_model_; }
    QString version() const;

    Q_INVOKABLE void refreshTorrents();

private:
    SessionManager session_;
    models::TorrentListModel torrent_model_;
};

} // namespace torrex::app
