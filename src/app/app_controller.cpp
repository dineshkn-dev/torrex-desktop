#include "app_controller.hpp"

#include <torrin/session_settings.hpp>
#include <torrin/torrent_preview.hpp>
#include <torrin/types.hpp>
#include <torrin/version.hpp>

#include <QDir>
#include <QFileInfo>
#include <QClipboard>
#include <QDesktopServices>
#include <QGuiApplication>
#include <QProcess>
#include <QStorageInfo>
#include <QLoggingCategory>
#include <QSettings>
#include <QStyleHints>
#include <QStandardPaths>
#include <QTimer>
#include <QUrl>

Q_LOGGING_CATEGORY(torrinPreview, "torrin.preview")

namespace torrin::app {

namespace {

QString builtin_default_download_path()
{
    const QString base =
        QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    const QString path = base + QStringLiteral("/Torrin");
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

QString formatByteSize(const qint64 bytes)
{
    if (bytes < 1024) {
        return QString::number(bytes) + QStringLiteral(" B");
    }
    if (bytes < 1024 * 1024) {
        return QString::number(bytes / 1024.0, 'f', 1) + QStringLiteral(" KB");
    }
    if (bytes < 1024LL * 1024 * 1024) {
        return QString::number(bytes / (1024.0 * 1024.0), 'f', 1) + QStringLiteral(" MB");
    }
    return QString::number(bytes / (1024.0 * 1024.0 * 1024.0), 'f', 1) + QStringLiteral(" GB");
}

constexpr int kAppearanceSystem = 0;
constexpr int kAppearanceLight = 1;
constexpr int kAppearanceDark = 2; // AMOLED-style true black (legacy mode 3 maps here)

int clampAppearanceMode(int mode)
{
    if (mode == 3) {
        return kAppearanceDark;
    }
    if (mode < kAppearanceSystem || mode > kAppearanceDark) {
        return kAppearanceSystem;
    }
    return mode;
}

QString normalizeAccentColorId(const QString& id)
{
    static const QStringList allowed{
        QStringLiteral("blue"),
        QStringLiteral("teal"),
        QStringLiteral("violet"),
        QStringLiteral("rose"),
        QStringLiteral("orange"),
        QStringLiteral("green"),
    };
    return allowed.contains(id) ? id : QStringLiteral("blue");
}

qint64 wantedBytesFromSelection(const QVariantList& files)
{
    qint64 total = 0;
    for (const QVariant& row : files) {
        const QVariantMap entry = row.toMap();
        if (entry.value(QStringLiteral("wanted"), true).toBool()) {
            total += entry.value(QStringLiteral("size")).toLongLong();
        }
    }
    return total;
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

    add_preview_poll_timer_ = new QTimer(this);
    add_preview_poll_timer_->setInterval(200);
    connect(add_preview_poll_timer_, &QTimer::timeout, this, &AppController::pollMagnetAddPreview);

    add_preview_timeout_timer_ = new QTimer(this);
    add_preview_timeout_timer_->setSingleShot(true);
    add_preview_timeout_timer_->setInterval(90000);
    connect(add_preview_timeout_timer_, &QTimer::timeout, this, [this] {
        if (add_preview_status_ != QStringLiteral("loading")) {
            return;
        }
        add_preview_status_ = QStringLiteral("error");
        add_preview_error_message_ =
            tr("Timed out loading torrent metadata. Check your network and try again.");
        add_preview_poll_timer_->stop();
        add_preview_timeout_timer_->stop();
        setStatusMessage(add_preview_error_message_);
        qCWarning(torrinPreview) << "preview timed out";
        emit addPreviewChanged();
    });
}

AppController::~AppController() { session_.shutdown(); }

QString AppController::version() const { return QString::fromUtf8(torrin::kVersion); }

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
    proxy_enabled_ = store.value(QStringLiteral("proxyEnabled"), false).toBool();
    proxy_type_ = store.value(QStringLiteral("proxyType"), 0).toInt();
    proxy_host_ = store.value(QStringLiteral("proxyHost")).toString();
    proxy_port_ = clampPort(store.value(QStringLiteral("proxyPort"), 1080).toInt());
    proxy_username_ = store.value(QStringLiteral("proxyUsername")).toString();
    proxy_password_ = store.value(QStringLiteral("proxyPassword")).toString();
    appearance_mode_ =
        clampAppearanceMode(store.value(QStringLiteral("appearanceMode"), kAppearanceSystem).toInt());
    accent_color_id_ =
        normalizeAccentColorId(store.value(QStringLiteral("accentColorId"), QStringLiteral("blue"))
                                  .toString());
    applyAppearanceColorScheme();
    emit sessionSettingsChanged();
    emit appearanceChanged();
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
    store.setValue(QStringLiteral("proxyEnabled"), proxy_enabled_);
    store.setValue(QStringLiteral("proxyType"), proxy_type_);
    store.setValue(QStringLiteral("proxyHost"), proxy_host_);
    store.setValue(QStringLiteral("proxyPort"), proxy_port_);
    store.setValue(QStringLiteral("proxyUsername"), proxy_username_);
    store.setValue(QStringLiteral("proxyPassword"), proxy_password_);
    store.setValue(QStringLiteral("appearanceMode"), appearance_mode_);
    store.setValue(QStringLiteral("accentColorId"), accent_color_id_);
}

void AppController::applyAppearanceColorScheme()
{
    auto* hints = QGuiApplication::styleHints();
    if (!hints) {
        return;
    }
    switch (appearance_mode_) {
    case kAppearanceLight:
        hints->setColorScheme(Qt::ColorScheme::Light);
        break;
    case kAppearanceDark:
        hints->setColorScheme(Qt::ColorScheme::Dark);
        break;
    default:
        hints->setColorScheme(Qt::ColorScheme::Unknown);
        break;
    }
}

void AppController::setAppearanceMode(int mode)
{
    const int clamped = clampAppearanceMode(mode);
    if (appearance_mode_ == clamped) {
        return;
    }
    appearance_mode_ = clamped;
    applyAppearanceColorScheme();
    emit appearanceChanged();
}

void AppController::setAccentColorId(const QString& id)
{
    const QString normalized = normalizeAccentColorId(id);
    if (accent_color_id_ == normalized) {
        return;
    }
    accent_color_id_ = normalized;
    emit appearanceChanged();
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
    if (proxy_enabled_ && !proxy_host_.trimmed().isEmpty()) {
        settings.proxy_type = proxy_type_;
        settings.proxy_host = proxy_host_.trimmed().toStdString();
        settings.proxy_port = proxy_port_;
        settings.proxy_username = proxy_username_.toStdString();
        settings.proxy_password = proxy_password_.toStdString();
    } else {
        settings.proxy_type = kProxyTypeNone;
    }
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

void AppController::setProxyEnabled(const bool enabled)
{
    if (proxy_enabled_ == enabled) {
        return;
    }
    proxy_enabled_ = enabled;
    emit sessionSettingsChanged();
}

void AppController::setProxyType(const int type)
{
    const int value = type < kProxyTypeNone || type > kProxyTypeHttp ? kProxyTypeNone : type;
    if (proxy_type_ == value) {
        return;
    }
    proxy_type_ = value;
    emit sessionSettingsChanged();
}

void AppController::setProxyHost(const QString& host)
{
    if (proxy_host_ == host) {
        return;
    }
    proxy_host_ = host;
    emit sessionSettingsChanged();
}

void AppController::setProxyPort(const int port)
{
    const int value = clampPort(port);
    if (proxy_port_ == value) {
        return;
    }
    proxy_port_ = value;
    emit sessionSettingsChanged();
}

void AppController::setProxyUsername(const QString& user)
{
    if (proxy_username_ == user) {
        return;
    }
    proxy_username_ = user;
    emit sessionSettingsChanged();
}

void AppController::setProxyPassword(const QString& password)
{
    if (proxy_password_ == password) {
        return;
    }
    proxy_password_ = password;
    emit sessionSettingsChanged();
}

void AppController::clearNotification()
{
    if (notification_message_.isEmpty()) {
        return;
    }
    notification_message_.clear();
    emit notificationMessageChanged();
}

void AppController::copyText(const QString& text)
{
    const QString trimmed = text.trimmed();
    if (trimmed.isEmpty()) {
        setStatusMessage(tr("Nothing to copy."));
        return;
    }
    if (QClipboard* clip = QGuiApplication::clipboard()) {
        clip->setText(trimmed);
        setStatusMessage(tr("Copied to clipboard."));
    }
}

QString AppController::magnetUriForTorrent(const QString& info_hash) const
{
    const QString id = info_hash.trimmed().toLower();
    if (id.isEmpty()) {
        return {};
    }
    return QStringLiteral("magnet:?xt=urn:btih:%1").arg(id);
}

void AppController::copyMagnetForTorrent(const QString& info_hash)
{
    const QString magnet = magnetUriForTorrent(info_hash);
    if (magnet.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    copyText(magnet);
}

void AppController::revealTorrentInFinder(const QString& info_hash)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }

    QString folder;
    for (const TorrentSnapshot& snap : session_.snapshots()) {
        if (QString::fromStdString(snap.info_hash.v1_hex).compare(id, Qt::CaseInsensitive) == 0) {
            folder = QString::fromStdString(snap.save_path);
            break;
        }
    }
    if (folder.isEmpty()) {
        setStatusMessage(tr("Torrent not found."));
        return;
    }

    const QFileInfo info(folder);
    const QString path = info.exists() ? info.absoluteFilePath() : folder;
    if (!QFileInfo::exists(path)) {
        setStatusMessage(tr("Save path does not exist yet."));
        return;
    }

#if defined(Q_OS_MACOS)
    QProcess::startDetached(QStringLiteral("open"),
                            {QStringLiteral("-R"), QDir::toNativeSeparators(path)});
#else
    QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(path).absolutePath()));
#endif
    setStatusMessage(tr("Revealed in file manager."));
}

void AppController::togglePauseResumeTorrent(const QString& info_hash)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    for (const TorrentSnapshot& snap : session_.snapshots()) {
        if (QString::fromStdString(snap.info_hash.v1_hex).compare(id, Qt::CaseInsensitive) != 0) {
            continue;
        }
        if (snap.state == TorrentState::Paused) {
            resumeTorrent(id);
        } else {
            pauseTorrent(id);
        }
        return;
    }
    setStatusMessage(tr("Torrent not found."));
}

void AppController::pauseAllTorrents()
{
    if (!session_.is_running()) {
        setStatusMessage(tr("Session is not running."));
        return;
    }
    int paused = 0;
    for (const TorrentSnapshot& snap : session_.snapshots()) {
        if (snap.state == TorrentState::Paused) {
            continue;
        }
        if (session_.pause_torrent(snap.info_hash.v1_hex).empty()) {
            ++paused;
        }
    }
    refreshTorrents();
    setStatusMessage(paused > 0 ? tr("Paused %1 torrent(s).").arg(paused)
                                : tr("No torrents to pause."));
}

void AppController::resumeAllTorrents()
{
    if (!session_.is_running()) {
        setStatusMessage(tr("Session is not running."));
        return;
    }
    int resumed = 0;
    for (const TorrentSnapshot& snap : session_.snapshots()) {
        if (snap.state != TorrentState::Paused) {
            continue;
        }
        if (session_.resume_torrent(snap.info_hash.v1_hex).empty()) {
            ++resumed;
        }
    }
    refreshTorrents();
    setStatusMessage(resumed > 0 ? tr("Resumed %1 torrent(s).").arg(resumed)
                                 : tr("No paused torrents."));
}

QString AppController::downloadFolderFreeSpaceText() const
{
    QStorageInfo storage(download_folder_);
    if (!storage.isValid() || !storage.isReady()) {
        return {};
    }
    const qint64 free_bytes = storage.bytesAvailable();
    if (free_bytes < 0) {
        return {};
    }
    return tr("%1 free on download volume").arg(formatByteSize(free_bytes));
}

void AppController::postNotification(const QString& message)
{
    if (message.isEmpty()) {
        return;
    }
    notification_message_ = message;
    emit notificationMessageChanged();
}

void AppController::detectCompletionNotifications()
{
    const std::vector<TorrentSnapshot> snaps = session_.snapshots();
    QHash<QString, int> still_active;

    for (const TorrentSnapshot& snap : snaps) {
        const QString id = QString::fromStdString(snap.info_hash.v1_hex);
        if (id.isEmpty()) {
            continue;
        }
        const int state = static_cast<int>(snap.state);
        still_active.insert(id, state);

        const int previous = torrent_state_cache_.value(id, -1);
        const bool was_active =
            previous == static_cast<int>(TorrentState::Downloading)
            || previous == static_cast<int>(TorrentState::Checking);
        const bool now_complete = state == static_cast<int>(TorrentState::Seeding)
                                  || snap.progress_percent >= 100;

        if (was_active && now_complete) {
            postNotification(tr("Download complete: %1")
                                 .arg(QString::fromStdString(snap.name)));
        }
        torrent_state_cache_[id] = state;
    }

    for (auto it = torrent_state_cache_.begin(); it != torrent_state_cache_.end();) {
        if (!still_active.contains(it.key())) {
            it = torrent_state_cache_.erase(it);
        } else {
            ++it;
        }
    }
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
    detectCompletionNotifications();
    const int count = torrent_model_.rowCount();
    setStatusMessage(tr("%1 torrent(s) — saving to %2").arg(count).arg(download_folder_));
}

void AppController::handleDroppedUrls(const QList<QUrl>& urls)
{
    if (urls.isEmpty()) {
        return;
    }

    int added = 0;
    for (const QUrl& url : urls) {
        if (url.isLocalFile()) {
            const QString path = url.toLocalFile();
            if (path.endsWith(QStringLiteral(".torrent"), Qt::CaseInsensitive)) {
                addTorrentFile(url);
                ++added;
            }
            continue;
        }

        const QString text = url.toString().trimmed();
        if (text.startsWith(QStringLiteral("magnet:?"), Qt::CaseInsensitive)) {
            addMagnetUri(text);
            ++added;
        }
    }

    if (added == 0) {
        setStatusMessage(tr("Drop a .torrent file or magnet link."));
    }
}

void AppController::clearAddPreview()
{
    resetAddPreviewUi(true);
}

void AppController::resetAddPreviewUi(bool cancel_staging)
{
    if (cancel_staging && !add_preview_info_hash_.isEmpty()) {
        (void)session_.cancel_magnet_preview(add_preview_info_hash_.toStdString());
    }
    add_preview_files_.clear();
    add_preview_title_.clear();
    add_preview_info_hash_.clear();
    add_preview_size_text_.clear();
    add_preview_status_ = QStringLiteral("idle");
    add_preview_error_message_.clear();
    add_preview_poll_timer_->stop();
    add_preview_timeout_timer_->stop();
    emit addPreviewChanged();
}

void AppController::failAddPreview(const QString& message)
{
    add_preview_status_ = QStringLiteral("error");
    add_preview_error_message_ = message;
    add_preview_poll_timer_->stop();
    add_preview_timeout_timer_->stop();
    setStatusMessage(message);
    qCWarning(torrinPreview) << "preview failed:" << message;
    emit addPreviewChanged();
}

void AppController::applyAddPreview(const torrin::TorrentAddPreview& preview)
{
    add_preview_title_ = QString::fromStdString(preview.name);
    add_preview_info_hash_ = QString::fromStdString(preview.info_hash_hex);

    QVariantList rows;
    rows.reserve(static_cast<int>(preview.files.size()));
    for (const torrin::TorrentPreviewFile& file : preview.files) {
        QVariantMap row;
        row.insert(QStringLiteral("path"), QString::fromStdString(file.path));
        row.insert(QStringLiteral("fileIndex"), file.index);
        row.insert(QStringLiteral("size"), static_cast<qlonglong>(file.size));
        row.insert(QStringLiteral("sizeText"), formatByteSize(static_cast<qint64>(file.size)));
        row.insert(QStringLiteral("wanted"), true);
        rows.push_back(row);
    }
    add_preview_files_ = rows;
    add_preview_size_text_ = formatByteSize(static_cast<qint64>(preview.total_size));
    add_preview_status_ = preview.files.empty() ? QStringLiteral("loading")
                                                  : QStringLiteral("ready");
    if (!preview.files.empty()) {
        add_preview_error_message_.clear();
    }
    emit addPreviewChanged();
}

void AppController::pollMagnetAddPreview()
{
    if (add_preview_info_hash_.isEmpty()) {
        add_preview_poll_timer_->stop();
        return;
    }

    const std::optional<torrin::TorrentAddPreview> preview =
        session_.magnet_preview(add_preview_info_hash_.toStdString());
    if (!preview.has_value()) {
        qCDebug(torrinPreview) << "poll: no staged preview yet for"
                               << add_preview_info_hash_.left(8) << "…";
        return;
    }

    const int file_count = static_cast<int>(preview->files.size());
    qCInfo(torrinPreview) << "poll:" << QString::fromStdString(preview->name) << "files"
                          << file_count;

    applyAddPreview(*preview);
    if (!preview->files.empty()) {
        add_preview_poll_timer_->stop();
        add_preview_timeout_timer_->stop();
        qCInfo(torrinPreview) << "preview ready with" << file_count << "files";
    }
}

std::vector<std::pair<int, int>> AppController::filePrioritiesFromSelection(
    const QVariantList& files)
{
    std::vector<std::pair<int, int>> priorities;
    priorities.reserve(static_cast<std::size_t>(files.size()));
    for (const QVariant& row : files) {
        const QVariantMap entry = row.toMap();
        const int index = entry.value(QStringLiteral("fileIndex")).toInt();
        const bool wanted = entry.value(QStringLiteral("wanted"), true).toBool();
        priorities.emplace_back(index, wanted ? 4 : 0);
    }
    return priorities;
}

bool AppController::loadTorrentFilePreview(const QUrl& file_url)
{
    clearAddPreview();
    if (!file_url.isLocalFile()) {
        add_preview_status_ = QStringLiteral("error");
        emit addPreviewChanged();
        setStatusMessage(tr("Could not open torrent file."));
        return false;
    }

    torrin::TorrentAddPreview preview;
    const std::string err =
        torrin::preview_torrent_file(file_url.toLocalFile().toStdString(), preview);
    if (!err.empty()) {
        add_preview_status_ = QStringLiteral("error");
        emit addPreviewChanged();
        setStatusMessage(QString::fromStdString(err));
        return false;
    }

    applyAddPreview(preview);
    add_preview_status_ = QStringLiteral("ready");
    emit addPreviewChanged();
    return true;
}

bool AppController::loadMagnetPreview(const QString& uri, const QString& save_path)
{
    const QString trimmed = uri.trimmed();
    if (!trimmed.startsWith(QStringLiteral("magnet:?"), Qt::CaseInsensitive)) {
        add_preview_status_ = QStringLiteral("error");
        emit addPreviewChanged();
        setStatusMessage(tr("Invalid magnet link — must start with magnet:?"));
        return false;
    }

    const QString folder = resolveSavePath(save_path);
    if (folder.isEmpty()) {
        add_preview_status_ = QStringLiteral("error");
        emit addPreviewChanged();
        setStatusMessage(tr("Choose a valid download folder."));
        return false;
    }

    clearAddPreview();

    torrin::TorrentAddPreview placeholder;
    const std::string parse_err =
        torrin::preview_magnet_uri(trimmed.toStdString(), placeholder);
    if (!parse_err.empty()) {
        add_preview_status_ = QStringLiteral("error");
        emit addPreviewChanged();
        setStatusMessage(QString::fromStdString(parse_err));
        return false;
    }

    add_preview_title_ = QString::fromStdString(placeholder.name);
    add_preview_status_ = QStringLiteral("loading");
    add_preview_error_message_.clear();
    emit addPreviewChanged();

    qCInfo(torrinPreview) << "loadMagnetPreview start" << add_preview_title_;

    std::string info_hash;
    const std::string err = session_.begin_magnet_preview(trimmed.toStdString(),
                                                          folder.toStdString(), info_hash);
    if (!err.empty()) {
        failAddPreview(QString::fromStdString(err));
        return false;
    }

    add_preview_info_hash_ = QString::fromStdString(info_hash);
    qCInfo(torrinPreview) << "staged hash" << add_preview_info_hash_.left(8) << "…";
    add_preview_poll_timer_->start();
    add_preview_timeout_timer_->start();

    QTimer::singleShot(250, this, [this] {
        pollMagnetAddPreview();
        if (add_preview_status_ != QStringLiteral("loading")) {
            return;
        }
        const std::optional<torrin::TorrentAddPreview> preview =
            session_.magnet_preview(add_preview_info_hash_.toStdString());
        if (preview.has_value()) {
            return;
        }
        const std::string async_err = session_.take_last_error();
        if (!async_err.empty()) {
            failAddPreview(QString::fromStdString(async_err));
        }
    });
    return true;
}

void AppController::cancelAddPreview() { clearAddPreview(); }

void AppController::addTorrentFileWithSelection(const QUrl& file_url,
                                                const QString& save_path,
                                                const QVariantList& files)
{
    if (!file_url.isLocalFile()) {
        setStatusMessage(tr("Could not open torrent file."));
        return;
    }

    const QString folder = resolveSavePath(save_path);
    if (folder.isEmpty()) {
        setStatusMessage(tr("Choose a valid download folder."));
        return;
    }
    setDefaultDownloadFolder(folder);

    const std::vector<std::pair<int, int>> priorities = filePrioritiesFromSelection(files);
    const std::string err = session_.add_torrent_file(file_url.toLocalFile().toStdString(),
                                                        folder.toStdString(), priorities);
    if (!err.empty()) {
        setStatusMessage(QString::fromStdString(err));
        return;
    }

    clearAddPreview();
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

void AppController::addMagnetWithSelection(const QString& uri,
                                           const QString& save_path,
                                           const QVariantList& files)
{
    const QString trimmed = uri.trimmed();
    const QString folder = resolveSavePath(save_path);
    if (folder.isEmpty()) {
        setStatusMessage(tr("Choose a valid download folder."));
        return;
    }
    setDefaultDownloadFolder(folder);

    const std::vector<std::pair<int, int>> priorities = filePrioritiesFromSelection(files);

    std::function<std::string()> op;
    if (!add_preview_info_hash_.isEmpty()) {
        const QString hash = add_preview_info_hash_;
        op = [this, hash, priorities] {
            return session_.finalize_magnet_preview(hash.toStdString(), priorities);
        };
    } else {
        op = [this, trimmed, folder, priorities] {
            return session_.add_magnet(trimmed.toStdString(), folder.toStdString(), priorities);
        };
    }

    const std::string err = op();
    if (!err.empty()) {
        setStatusMessage(QString::fromStdString(err));
        return;
    }

    resetAddPreviewUi(false);
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

void AppController::stopSeeding(const QString& info_hash)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    runTorrentOp(
        [this, id] { return session_.stop_seeding(id.toStdString()); },
        tr("Upload stopped."));
}

void AppController::resumeSeeding(const QString& info_hash)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    runTorrentOp(
        [this, id] { return session_.resume_seeding(id.toStdString()); },
        tr("Upload resumed."));
}

void AppController::forceRecheck(const QString& info_hash)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    runTorrentOp(
        [this, id] { return session_.force_recheck(id.toStdString()); },
        tr("Recheck started."));
}

void AppController::forceReannounce(const QString& info_hash)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    runTorrentOp(
        [this, id] { return session_.force_reannounce(id.toStdString()); },
        tr("Reannounce sent."));
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

void AppController::setTorrentFilePriority(const QString& info_hash,
                                           const int file_index,
                                           const int priority)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    runTorrentOp(
        [this, id, file_index, priority] {
            return session_.set_file_priority(id.toStdString(), file_index, priority);
        },
        tr("File priority updated."));
}

void AppController::setTorrentSequentialDownload(const QString& info_hash, const bool enabled)
{
    const QString id = info_hash.trimmed();
    if (id.isEmpty()) {
        setStatusMessage(tr("No torrent selected."));
        return;
    }
    runTorrentOp(
        [this, id, enabled] {
            return session_.set_sequential_download(id.toStdString(), enabled);
        },
        enabled ? tr("Sequential download enabled.") : tr("Sequential download disabled."));
}

void AppController::setStatusMessage(const QString& message)
{
    if (status_message_ == message) {
        return;
    }
    status_message_ = message;
    emit statusMessageChanged();
}

} // namespace torrin::app
