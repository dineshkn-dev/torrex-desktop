#include "torrent_list_model.hpp"

#include <torrin/torrent_filter.hpp>

#include <QVariantMap>
#include <QStringList>

namespace torrin::models {

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
        if (torrent_matches_filter(items_[static_cast<std::size_t>(i)],
                                   active_filter_.toUtf8().constData())) {
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
        ++data_revision_;
        emit dataRevisionChanged();
        emit snapshotsUpdated();
        return;
    }

    beginResetModel();
    endResetModel();
    emit countChanged();
    ++data_revision_;
    emit dataRevisionChanged();
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
    ++data_revision_;
    emit dataRevisionChanged();
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

int TorrentListModel::rowForInfoHash(const QString& info_hash_hex) const
{
    const QString id = info_hash_hex.trimmed();
    if (id.isEmpty()) {
        return -1;
    }
    for (int row = 0; row < static_cast<int>(filtered_rows_.size()); ++row) {
        if (infoHashAt(row).compare(id, Qt::CaseInsensitive) == 0) {
            return row;
        }
    }
    return -1;
}

QStringList TorrentListModel::filePathsAt(const int row) const
{
    const TorrentSnapshot* item = snapshotAt(row);
    if (item == nullptr) {
        return {};
    }
    QStringList paths;
    paths.reserve(static_cast<int>(item->files.size()));
    for (const TorrentFileSnapshot& file : item->files) {
        paths.push_back(QString::fromStdString(file.path));
    }
    return paths;
}

QVariantList TorrentListModel::fileEntriesAt(const int row) const
{
    const TorrentSnapshot* item = snapshotAt(row);
    if (item == nullptr) {
        return {};
    }
    QVariantList entries;
    entries.reserve(static_cast<int>(item->files.size()));
    for (const TorrentFileSnapshot& file : item->files) {
        QVariantMap entry;
        entry.insert(QStringLiteral("path"), QString::fromStdString(file.path));
        entry.insert(QStringLiteral("fileIndex"), file.index);
        entry.insert(QStringLiteral("priority"), file.priority);
        entry.insert(QStringLiteral("progress"), file.progress_percent);
        entries.push_back(entry);
    }
    return entries;
}

bool TorrentListModel::sequentialDownloadAt(const int row) const
{
    const TorrentSnapshot* item = snapshotAt(row);
    return item != nullptr && item->sequential_download;
}

} // namespace torrin::models
