#pragma once

#include <torrin/session_manager.hpp>
#include <torrin/torrent_preview.hpp>

#include "torrent_list_model.hpp"

#include <QHash>
#include <QObject>
#include <QTimer>
#include <QUrl>
#include <QVariantList>

#include <functional>
#include <utility>
#include <vector>

namespace torrin::app {

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
    Q_PROPERTY(int appearanceMode READ appearanceMode WRITE setAppearanceMode NOTIFY
                   appearanceChanged)
    Q_PROPERTY(QString accentColorId READ accentColorId WRITE setAccentColorId NOTIFY
                   appearanceChanged)
    Q_PROPERTY(QVariantList addPreviewFiles READ addPreviewFiles NOTIFY addPreviewChanged)
    Q_PROPERTY(QString addPreviewTitle READ addPreviewTitle NOTIFY addPreviewChanged)
    Q_PROPERTY(QString addPreviewStatus READ addPreviewStatus NOTIFY addPreviewChanged)
    Q_PROPERTY(QString addPreviewErrorMessage READ addPreviewErrorMessage NOTIFY addPreviewChanged)
    Q_PROPERTY(QString addPreviewInfoHash READ addPreviewInfoHash NOTIFY addPreviewChanged)
    Q_PROPERTY(QString addPreviewSizeText READ addPreviewSizeText NOTIFY addPreviewChanged)

public:
    explicit AppController(QObject* parent = nullptr);
    ~AppController() override;

    models::TorrentListModel* torrents() { return &torrent_model_; }
    QString version() const;

    Q_INVOKABLE void refreshTorrents();
    Q_INVOKABLE void addMagnetUri(const QString& uri, const QString& save_path = {});
    Q_INVOKABLE void addTorrentFile(const QUrl& file_url, const QString& save_path = {});
    Q_INVOKABLE bool loadTorrentFilePreview(const QUrl& file_url);
    Q_INVOKABLE bool loadMagnetPreview(const QString& uri, const QString& save_path = {});
    Q_INVOKABLE void cancelAddPreview();
    Q_INVOKABLE void addTorrentFileWithSelection(const QUrl& file_url,
                                                 const QString& save_path,
                                                 const QVariantList& files);
    Q_INVOKABLE void addMagnetWithSelection(const QString& uri,
                                            const QString& save_path,
                                            const QVariantList& files);
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

    [[nodiscard]] int appearanceMode() const { return appearance_mode_; }
    void setAppearanceMode(int mode);

    [[nodiscard]] QString accentColorId() const { return accent_color_id_; }
    void setAccentColorId(const QString& id);

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
    void appearanceChanged();
    void addPreviewChanged();

private:
    [[nodiscard]] QVariantList addPreviewFiles() const { return add_preview_files_; }
    [[nodiscard]] QString addPreviewTitle() const { return add_preview_title_; }
    [[nodiscard]] QString addPreviewStatus() const { return add_preview_status_; }
    [[nodiscard]] QString addPreviewErrorMessage() const { return add_preview_error_message_; }
    [[nodiscard]] QString addPreviewInfoHash() const { return add_preview_info_hash_; }
    [[nodiscard]] QString addPreviewSizeText() const { return add_preview_size_text_; }

    void clearAddPreview();
    void resetAddPreviewUi(bool cancel_staging);
    void failAddPreview(const QString& message);
    void applyAddPreview(const torrin::TorrentAddPreview& preview);
    void pollMagnetAddPreview();
    [[nodiscard]] static std::vector<std::pair<int, int>> filePrioritiesFromSelection(
        const QVariantList& files);
    [[nodiscard]] QString resolveSavePath(const QString& save_path) const;
    void setStatusMessage(const QString& message);
    void postNotification(const QString& message);
    void detectCompletionNotifications();
    void runTorrentOp(const std::function<std::string()>& op,
                      const QString& success_message);
    void persistSessionSettings();
    void pushSettingsToEngine();
    void applyAppearanceColorScheme();
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
    int appearance_mode_ = 0;
    QString accent_color_id_{QStringLiteral("blue")};
    QHash<QString, int> torrent_state_cache_;
    QVariantList add_preview_files_;
    QString add_preview_title_;
    QString add_preview_status_{QStringLiteral("idle")};
    QString add_preview_error_message_;
    QString add_preview_info_hash_;
    QString add_preview_size_text_;
    QTimer* add_preview_poll_timer_ = nullptr;
    QTimer* add_preview_timeout_timer_ = nullptr;
    SessionManager session_;
    models::TorrentListModel torrent_model_;
};

} // namespace torrin::app
