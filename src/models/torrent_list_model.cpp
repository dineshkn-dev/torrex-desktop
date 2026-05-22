#include "torrent_list_model.hpp"

namespace torrex::models {

namespace {

bool matches_filter(const TorrentSnapshot& item, const QString& filter_id)
{
    if (filter_id == QStringLiteral("all")) {
        return true;
    }
    if (filter_id == QStringLiteral("downloading")) {
        return item.state == TorrentState::Downloading || item.state == TorrentState::Checking
            || item.state == TorrentState::Idle;
    }
    if (filter_id == QStringLiteral("seeding")) {
        return item.state == TorrentState::Seeding;
    }
    if (filter_id == QStringLiteral("paused")) {
        return item.state == TorrentState::Paused;
    }
    return true;
}

} // namespace

TorrentListModel::TorrentListModel(SessionManager& session, QObject* parent)
    : QAbstractListModel(parent), session_(session)
{
}

int TorrentListModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return static_cast<int>(filtered_rows_.size());
}

QVariant TorrentListModel::data(const QModelIndex& index, int role) const
{
    const TorrentSnapshot* item = snapshotAt(index.row());
    if (item == nullptr) {
        return {};
    }

    switch (role) {
    case NameRole:
        return QString::fromStdString(item->name);
    case InfoHashRole:
        return QString::fromStdString(item->info_hash.v1_hex);
    case StateRole:
        return static_cast<int>(item->state);
    case ProgressRole:
        return item->progress_percent;
    case DownloadRateRole:
        return static_cast<qlonglong>(item->download_rate);
    case UploadRateRole:
        return static_cast<qlonglong>(item->upload_rate);
    case SavePathRole:
        return QString::fromStdString(item->save_path);
    default:
        return {};
    }
}

QHash<int, QByteArray> TorrentListModel::roleNames() const
{
    return {
        {NameRole, "name"},
        {InfoHashRole, "infoHash"},
        {StateRole, "state"},
        {ProgressRole, "progress"},
        {DownloadRateRole, "downloadRate"},
        {UploadRateRole, "uploadRate"},
        {SavePathRole, "savePath"},
    };
}

void TorrentListModel::rebuildFilteredRows()
{
    filtered_rows_.clear();
    filtered_rows_.reserve(items_.size());
    for (int i = 0; i < static_cast<int>(items_.size()); ++i) {
        if (matches_filter(items_[static_cast<std::size_t>(i)], active_filter_)) {
            filtered_rows_.push_back(i);
        }
    }
}

void TorrentListModel::refresh()
{
    const std::vector<TorrentSnapshot> next = session_.snapshots();
    const bool count_changed = next.size() != items_.size();
    items_ = next;
    rebuildFilteredRows();

    if (!count_changed && !filtered_rows_.empty()) {
        emit dataChanged(index(0), index(static_cast<int>(filtered_rows_.size()) - 1));
        emit snapshotsUpdated();
        return;
    }

    beginResetModel();
    endResetModel();
    emit countChanged();
    emit snapshotsUpdated();
}

void TorrentListModel::setFilter(const QString& filter_id)
{
    const QString id = filter_id.trimmed().toLower();
    QString normalized = QStringLiteral("all");
    if (id == QStringLiteral("downloading") || id == QStringLiteral("seeding")
        || id == QStringLiteral("paused")) {
        normalized = id;
    }
    if (normalized == active_filter_) {
        return;
    }
    active_filter_ = normalized;
    rebuildFilteredRows();
    beginResetModel();
    endResetModel();
    emit countChanged();
    emit activeFilterChanged();
    emit snapshotsUpdated();
}

const TorrentSnapshot* TorrentListModel::snapshotAt(const int row) const
{
    if (row < 0 || row >= static_cast<int>(filtered_rows_.size())) {
        return nullptr;
    }
    const int source = filtered_rows_[static_cast<std::size_t>(row)];
    return &items_[static_cast<std::size_t>(source)];
}

QString TorrentListModel::infoHashAt(const int row) const
{
    const TorrentSnapshot* item = snapshotAt(row);
    return item == nullptr ? QString{} : QString::fromStdString(item->info_hash.v1_hex);
}

QString TorrentListModel::nameAt(const int row) const
{
    const TorrentSnapshot* item = snapshotAt(row);
    return item == nullptr ? QString{} : QString::fromStdString(item->name);
}

int TorrentListModel::stateAt(const int row) const
{
    const TorrentSnapshot* item = snapshotAt(row);
    return item == nullptr ? -1 : static_cast<int>(item->state);
}

int TorrentListModel::progressAt(const int row) const
{
    const TorrentSnapshot* item = snapshotAt(row);
    return item == nullptr ? 0 : item->progress_percent;
}

QString TorrentListModel::savePathAt(const int row) const
{
    const TorrentSnapshot* item = snapshotAt(row);
    return item == nullptr ? QString{} : QString::fromStdString(item->save_path);
}

qint64 TorrentListModel::downloadRateAt(const int row) const
{
    const TorrentSnapshot* item = snapshotAt(row);
    return item == nullptr ? 0 : item->download_rate;
}

qint64 TorrentListModel::uploadRateAt(const int row) const
{
    const TorrentSnapshot* item = snapshotAt(row);
    return item == nullptr ? 0 : item->upload_rate;
}

} // namespace torrex::models
