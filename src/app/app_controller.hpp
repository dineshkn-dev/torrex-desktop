#pragma once

#include <torrex/session_manager.hpp>

#include "torrent_list_model.hpp"

#include <QHash>
#include <QObject>
#include <QUrl>

#include <functional>

namespace torrex::app {

class AppController : public QObject {
    Q_OBJECT
    Q_PROPERTY(models::TorrentListModel* torrents READ torrents CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(QString notificationMessage READ notificationMessage NOTIFY
                   notificationMessageChanged)
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
    Q_PROPERTY(bool proxyEnabled READ proxyEnabled WRITE setProxyEnabled NOTIFY
                   sessionSettingsChanged)
    Q_PROPERTY(int proxyType READ proxyType WRITE setProxyType NOTIFY sessionSettingsChanged)
    Q_PROPERTY(QString proxyHost READ proxyHost WRITE setProxyHost NOTIFY sessionSettingsChanged)
    Q_PROPERTY(int proxyPort READ proxyPort WRITE setProxyPort NOTIFY sessionSettingsChanged)
    Q_PROPERTY(QString proxyUsername READ proxyUsername WRITE setProxyUsername NOTIFY
                   sessionSettingsChanged)
    Q_PROPERTY(QString proxyPassword READ proxyPassword WRITE setProxyPassword NOTIFY
                   sessionSettingsChanged)

public:
    explicit AppController(QObject* parent = nullptr);
    ~AppController() override;

    models::TorrentListModel* torrents() { return &torrent_model_; }
    QString version() const;

    Q_INVOKABLE void refreshTorrents();
    Q_INVOKABLE void addMagnetUri(const QString& uri, const QString& save_path = {});
    Q_INVOKABLE void addTorrentFile(const QUrl& file_url, const QString& save_path = {});
    Q_INVOKABLE void handleDroppedUrls(const QList<QUrl>& urls);

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

    [[nodiscard]] bool proxyEnabled() const { return proxy_enabled_; }
    void setProxyEnabled(bool enabled);

    [[nodiscard]] int proxyType() const { return proxy_type_; }
    void setProxyType(int type);

    [[nodiscard]] QString proxyHost() const { return proxy_host_; }
    void setProxyHost(const QString& host);

    [[nodiscard]] int proxyPort() const { return proxy_port_; }
    void setProxyPort(int port);

    [[nodiscard]] QString proxyUsername() const { return proxy_username_; }
    void setProxyUsername(const QString& user);

    [[nodiscard]] QString proxyPassword() const { return proxy_password_; }
    void setProxyPassword(const QString& password);

    Q_INVOKABLE void applySessionSettings();
    Q_INVOKABLE void loadSessionSettingsFromStore();
    Q_INVOKABLE void clearNotification();

    Q_INVOKABLE void pauseTorrent(const QString& info_hash);
    Q_INVOKABLE void resumeTorrent(const QString& info_hash);
    Q_INVOKABLE void removeTorrent(const QString& info_hash, bool delete_files);
    Q_INVOKABLE void setTorrentFilePriority(const QString& info_hash,
                                            int file_index,
                                            int priority);
    Q_INVOKABLE void setTorrentSequentialDownload(const QString& info_hash, bool enabled);

    [[nodiscard]] QString statusMessage() const { return status_message_; }
    [[nodiscard]] QString notificationMessage() const { return notification_message_; }

signals:
    void statusMessageChanged();
    void notificationMessageChanged();
    void defaultDownloadFolderChanged();
    void sessionSettingsChanged();

private:
    [[nodiscard]] QString resolveSavePath(const QString& save_path) const;
    void setStatusMessage(const QString& message);
    void postNotification(const QString& message);
    void detectCompletionNotifications();
    void runTorrentOp(const std::function<std::string()>& op,
                      const QString& success_message);
    void persistSessionSettings();
    void pushSettingsToEngine();
    [[nodiscard]] SessionSettings engineSettingsFromProperties() const;

    QString status_message_ = QStringLiteral("Ready");
    QString notification_message_;
    QString download_folder_;
    int download_limit_kbps_ = 0;
    int upload_limit_kbps_ = 0;
    int listen_port_ = 6881;
    bool enable_upnp_ = true;
    bool enable_natpmp_ = true;
    bool enable_dht_ = true;
    bool enable_lsd_ = true;
    bool proxy_enabled_ = false;
    int proxy_type_ = 0;
    QString proxy_host_;
    int proxy_port_ = 1080;
    QString proxy_username_;
    QString proxy_password_;
    QHash<QString, int> torrent_state_cache_;
    SessionManager session_;
    models::TorrentListModel torrent_model_;
};

} // namespace torrex::app
