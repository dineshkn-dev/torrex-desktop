#pragma once

#include <torrex/session_manager.hpp>

#include "torrent_list_model.hpp"

#include <QObject>

#include <functional>
#include <memory>

namespace torrex::app {

class AppController : public QObject {
    Q_OBJECT
    Q_PROPERTY(models::TorrentListModel* torrents READ torrents CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(QString defaultDownloadFolder READ defaultDownloadFolder WRITE
                   setDefaultDownloadFolder NOTIFY defaultDownloadFolderChanged)

public:
    explicit AppController(QObject* parent = nullptr);
    ~AppController() override;

    models::TorrentListModel* torrents() { return &torrent_model_; }
    QString version() const;

    Q_INVOKABLE void refreshTorrents();
    Q_INVOKABLE void addMagnetUri(const QString& uri, const QString& save_path = {});
    Q_INVOKABLE void addTorrentFile(const QUrl& file_url, const QString& save_path = {});

    [[nodiscard]] QString defaultDownloadFolder() const { return download_folder_; }
    void setDefaultDownloadFolder(const QString& path);
    Q_INVOKABLE void pauseTorrent(const QString& info_hash);
    Q_INVOKABLE void resumeTorrent(const QString& info_hash);
    Q_INVOKABLE void removeTorrent(const QString& info_hash, bool delete_files);

    [[nodiscard]] QString statusMessage() const { return status_message_; }

signals:
    void statusMessageChanged();
    void defaultDownloadFolderChanged();

private:
    [[nodiscard]] QString resolveSavePath(const QString& save_path) const;
    void setStatusMessage(const QString& message);
    void runTorrentOp(const std::function<std::string()>& op,
                      const QString& success_message);

    QString status_message_ = QStringLiteral("Ready");
    QString download_folder_;
    SessionManager session_;
    models::TorrentListModel torrent_model_;
};

} // namespace torrex::app
