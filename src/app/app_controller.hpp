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
    Q_PROPERTY(int downloadLimitKbps READ downloadLimitKbps WRITE setDownloadLimitKbps NOTIFY
                   sessionSettingsChanged)
    Q_PROPERTY(int uploadLimitKbps READ uploadLimitKbps WRITE setUploadLimitKbps NOTIFY
                   sessionSettingsChanged)
    Q_PROPERTY(int listenPort READ listenPort WRITE setListenPort NOTIFY sessionSettingsChanged)
    Q_PROPERTY(bool enableUpnp READ enableUpnp WRITE setEnableUpnp NOTIFY sessionSettingsChanged)
    Q_PROPERTY(bool enableNatPmp READ enableNatPmp WRITE setEnableNatPmp NOTIFY
                   sessionSettingsChanged)
    Q_PROPERTY(bool enableDht READ enableDht WRITE setEnableDht NOTIFY sessionSettingsChanged)
    Q_PROPERTY(bool enableLsd READ enableLsd WRITE setEnableLsd NOTIFY sessionSettingsChanged)

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

    [[nodiscard]] int downloadLimitKbps() const { return download_limit_kbps_; }
    void setDownloadLimitKbps(int kbps);

    [[nodiscard]] int uploadLimitKbps() const { return upload_limit_kbps_; }
    void setUploadLimitKbps(int kbps);

    [[nodiscard]] int listenPort() const { return listen_port_; }
    void setListenPort(int port);

    [[nodiscard]] bool enableUpnp() const { return enable_upnp_; }
    void setEnableUpnp(bool enabled);

    [[nodiscard]] bool enableNatPmp() const { return enable_natpmp_; }
    void setEnableNatPmp(bool enabled);

    [[nodiscard]] bool enableDht() const { return enable_dht_; }
    void setEnableDht(bool enabled);

    [[nodiscard]] bool enableLsd() const { return enable_lsd_; }
    void setEnableLsd(bool enabled);

    Q_INVOKABLE void applySessionSettings();
    Q_INVOKABLE void loadSessionSettingsFromStore();

    Q_INVOKABLE void pauseTorrent(const QString& info_hash);
    Q_INVOKABLE void resumeTorrent(const QString& info_hash);
    Q_INVOKABLE void removeTorrent(const QString& info_hash, bool delete_files);

    [[nodiscard]] QString statusMessage() const { return status_message_; }

signals:
    void statusMessageChanged();
    void defaultDownloadFolderChanged();
    void sessionSettingsChanged();

private:
    [[nodiscard]] QString resolveSavePath(const QString& save_path) const;
    void setStatusMessage(const QString& message);
    void runTorrentOp(const std::function<std::string()>& op,
                      const QString& success_message);
    void persistSessionSettings();
    void pushSettingsToEngine();
    [[nodiscard]] SessionSettings engineSettingsFromProperties() const;

    QString status_message_ = QStringLiteral("Ready");
    QString download_folder_;
    int download_limit_kbps_ = 0;
    int upload_limit_kbps_ = 0;
    int listen_port_ = 6881;
    bool enable_upnp_ = true;
    bool enable_natpmp_ = true;
    bool enable_dht_ = true;
    bool enable_lsd_ = true;
    SessionManager session_;
    models::TorrentListModel torrent_model_;
};

} // namespace torrex::app
