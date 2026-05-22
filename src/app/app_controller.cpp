#include "app_controller.hpp"

#include <torrex/version.hpp>

#include <QDir>
#include <QFileInfo>
#include <QSettings>
#include <QStandardPaths>
#include <QTimer>
#include <QUrl>

namespace torrex::app {

namespace {

QString builtin_default_download_path()
{
    const QString base =
        QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    const QString path = base + QStringLiteral("/Torrex");
    QDir().mkpath(path);
    return path;
}

QString session_data_directory()
{
    const QString base =
        QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    const QString path = base + QStringLiteral("/session");
    QDir().mkpath(path);
    return path;
}

int clampPort(int port)
{
    if (port < kMinListenPort || port > kMaxListenPort) {
        return 6881;
    }
    return port;
}

int clampKbps(int kbps)
{
    return kbps < 0 ? 0 : kbps;
}

} // namespace

AppController::AppController(QObject* parent)
    : QObject(parent)
    , session_(session_data_directory().toStdString())
    , torrent_model_(session_, this)
{
    download_folder_ =
        QSettings().value(QStringLiteral("downloadFolder"), builtin_default_download_path())
            .toString();
    if (download_folder_.isEmpty()) {
        download_folder_ = builtin_default_download_path();
    }
    QDir().mkpath(download_folder_);

    loadSessionSettingsFromStore();
    pushSettingsToEngine();

    session_.start();
    setStatusMessage(tr("Ready — downloads go to %1").arg(download_folder_));

    auto* timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &AppController::refreshTorrents);
    timer->start(500);
}

AppController::~AppController() { session_.shutdown(); }

QString AppController::version() const { return QString::fromUtf8(torrex::kVersion); }

void AppController::loadSessionSettingsFromStore()
{
    QSettings store;
    download_limit_kbps_ = clampKbps(store.value(QStringLiteral("downloadLimitKbps"), 0).toInt());
    upload_limit_kbps_ = clampKbps(store.value(QStringLiteral("uploadLimitKbps"), 0).toInt());
    listen_port_ = clampPort(store.value(QStringLiteral("listenPort"), 6881).toInt());
    enable_upnp_ = store.value(QStringLiteral("enableUpnp"), true).toBool();
    enable_natpmp_ = store.value(QStringLiteral("enableNatPmp"), true).toBool();
    enable_dht_ = store.value(QStringLiteral("enableDht"), true).toBool();
    enable_lsd_ = store.value(QStringLiteral("enableLsd"), true).toBool();
    emit sessionSettingsChanged();
}

void AppController::persistSessionSettings()
{
    QSettings store;
    store.setValue(QStringLiteral("downloadLimitKbps"), download_limit_kbps_);
    store.setValue(QStringLiteral("uploadLimitKbps"), upload_limit_kbps_);
    store.setValue(QStringLiteral("listenPort"), listen_port_);
    store.setValue(QStringLiteral("enableUpnp"), enable_upnp_);
    store.setValue(QStringLiteral("enableNatPmp"), enable_natpmp_);
    store.setValue(QStringLiteral("enableDht"), enable_dht_);
    store.setValue(QStringLiteral("enableLsd"), enable_lsd_);
}

SessionSettings AppController::engineSettingsFromProperties() const
{
    SessionSettings settings;
    settings.download_rate_limit =
        download_limit_kbps_ > 0 ? download_limit_kbps_ * 1024 : 0;
    settings.upload_rate_limit = upload_limit_kbps_ > 0 ? upload_limit_kbps_ * 1024 : 0;
    settings.listen_port = listen_port_;
    settings.enable_upnp = enable_upnp_;
    settings.enable_natpmp = enable_natpmp_;
    settings.enable_dht = enable_dht_;
    settings.enable_lsd = enable_lsd_;
    return settings;
}

void AppController::pushSettingsToEngine()
{
    session_.set_session_settings(engineSettingsFromProperties());
}

void AppController::applySessionSettings()
{
    listen_port_ = clampPort(listen_port_);
    download_limit_kbps_ = clampKbps(download_limit_kbps_);
    upload_limit_kbps_ = clampKbps(upload_limit_kbps_);
    persistSessionSettings();
    pushSettingsToEngine();
    emit sessionSettingsChanged();
    setStatusMessage(tr("Settings applied."));
}

void AppController::setDownloadLimitKbps(const int kbps)
{
    const int value = clampKbps(kbps);
    if (download_limit_kbps_ == value) {
        return;
    }
    download_limit_kbps_ = value;
    emit sessionSettingsChanged();
}

void AppController::setUploadLimitKbps(const int kbps)
{
    const int value = clampKbps(kbps);
    if (upload_limit_kbps_ == value) {
        return;
    }
    upload_limit_kbps_ = value;
    emit sessionSettingsChanged();
}

void AppController::setListenPort(const int port)
{
    const int value = clampPort(port);
    if (listen_port_ == value) {
        return;
    }
    listen_port_ = value;
    emit sessionSettingsChanged();
}

void AppController::setEnableUpnp(const bool enabled)
{
    if (enable_upnp_ == enabled) {
        return;
    }
    enable_upnp_ = enabled;
    emit sessionSettingsChanged();
}

void AppController::setEnableNatPmp(const bool enabled)
{
    if (enable_natpmp_ == enabled) {
        return;
    }
    enable_natpmp_ = enabled;
    emit sessionSettingsChanged();
}

void AppController::setEnableDht(const bool enabled)
{
    if (enable_dht_ == enabled) {
        return;
    }
    enable_dht_ = enabled;
    emit sessionSettingsChanged();
}

void AppController::setEnableLsd(const bool enabled)
{
    if (enable_lsd_ == enabled) {
        return;
    }
    enable_lsd_ = enabled;
    emit sessionSettingsChanged();
}

void AppController::setDefaultDownloadFolder(const QString& path)
{
    const QString trimmed = path.trimmed();
    if (trimmed.isEmpty() || trimmed == download_folder_) {
        return;
    }
    const QFileInfo info(trimmed);
    if (!info.isDir()) {
        setStatusMessage(tr("Download folder does not exist."));
        return;
    }
    download_folder_ = info.absoluteFilePath();
    QDir().mkpath(download_folder_);
    QSettings().setValue(QStringLiteral("downloadFolder"), download_folder_);
    emit defaultDownloadFolderChanged();
}

QString AppController::resolveSavePath(const QString& save_path) const
{
    QString path = save_path.trimmed();
    if (path.isEmpty()) {
        path = download_folder_;
    }
    const QFileInfo info(path);
    if (!info.isDir()) {
        return {};
    }
    return info.absoluteFilePath();
}

void AppController::refreshTorrents()
{
    torrent_model_.refresh();
    const int count = torrent_model_.rowCount();
    setStatusMessage(tr("%1 torrent(s) — saving to %2").arg(count).arg(download_folder_));
}

void AppController::addMagnetUri(const QString& uri, const QString& save_path)
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

    const QString folder = resolveSavePath(save_path);
    if (folder.isEmpty()) {
        setStatusMessage(tr("Choose a valid download folder."));
        return;
    }
    setDefaultDownloadFolder(folder);

    const std::string err =
        session_.add_magnet(trimmed.toStdString(), folder.toStdString());
    if (!err.empty()) {
        setStatusMessage(QString::fromStdString(err));
        return;
    }

    QTimer::singleShot(300, this, [this, folder] {
        const std::string async_err = session_.take_last_error();
        if (!async_err.empty()) {
            setStatusMessage(QString::fromStdString(async_err));
        } else {
            refreshTorrents();
            setStatusMessage(tr("Magnet added — downloading to %1").arg(folder));
        }
    });
}

void AppController::addTorrentFile(const QUrl& file_url, const QString& save_path)
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

    const QString folder = resolveSavePath(save_path);
    if (folder.isEmpty()) {
        setStatusMessage(tr("Choose a valid download folder."));
        return;
    }
    setDefaultDownloadFolder(folder);

    const std::string err =
        session_.add_torrent_file(path.toStdString(), folder.toStdString());
    if (!err.empty()) {
        setStatusMessage(QString::fromStdString(err));
        return;
    }

    QTimer::singleShot(300, this, [this, folder] {
        const std::string async_err = session_.take_last_error();
        if (!async_err.empty()) {
            setStatusMessage(QString::fromStdString(async_err));
        } else {
            refreshTorrents();
            setStatusMessage(tr("Torrent added — downloading to %1").arg(folder));
        }
    });
}

void AppController::runTorrentOp(const std::function<std::string()>& op,
                                 const QString& success_message)
{
    const std::string err = op();
    if (!err.empty()) {
        setStatusMessage(QString::fromStdString(err));
        return;
    }

    QTimer::singleShot(300, this, [this, success_message] {
        const std::string async_err = session_.take_last_error();
        if (!async_err.empty()) {
            setStatusMessage(QString::fromStdString(async_err));
        } else {
            refreshTorrents();
            setStatusMessage(success_message);
        }
    });
}

void AppController::pauseTorrent(const QString& info_hash)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    runTorrentOp(
        [this, id] { return session_.pause_torrent(id.toStdString()); },
        tr("Torrent paused."));
}

void AppController::resumeTorrent(const QString& info_hash)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    runTorrentOp(
        [this, id] { return session_.resume_torrent(id.toStdString()); },
        tr("Torrent resumed."));
}

void AppController::removeTorrent(const QString& info_hash, const bool delete_files)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    runTorrentOp(
        [this, id, delete_files] {
            return session_.remove_torrent(id.toStdString(), delete_files);
        },
        delete_files ? tr("Torrent removed and data deleted.")
                     : tr("Torrent removed."));
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
