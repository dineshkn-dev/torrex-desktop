#include "torrent_list_model.hpp"

namespace torrex::models {

TorrentListModel::TorrentListModel(SessionManager& session, QObject* parent)
    : QAbstractListModel(parent), session_(session)
{
}

int TorrentListModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return static_cast<int>(items_.size());
}

QVariant TorrentListModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() < 0
        || index.row() >= static_cast<int>(items_.size())) {
        return {};
    }

    const auto& item = items_[static_cast<std::size_t>(index.row())];
    switch (role) {
    case NameRole:
        return QString::fromStdString(item.name);
    case InfoHashRole:
        return QString::fromStdString(item.info_hash.v1_hex);
    case StateRole:
        return static_cast<int>(item.state);
    case ProgressRole:
        return item.progress_percent;
    case DownloadRateRole:
        return static_cast<qlonglong>(item.download_rate);
    case UploadRateRole:
        return static_cast<qlonglong>(item.upload_rate);
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
    };
}

void TorrentListModel::refresh()
{
    const std::vector<TorrentSnapshot> next = session_.snapshots();
    if (next.size() == items_.size()) {
        items_ = next;
        if (!items_.empty()) {
            emit dataChanged(index(0), index(static_cast<int>(items_.size()) - 1));
        }
        emit snapshotsUpdated();
        return;
    }

    beginResetModel();
    items_ = next;
    endResetModel();
    emit countChanged();
    emit snapshotsUpdated();
}

QString TorrentListModel::nameAt(const int row) const
{
    if (row < 0 || row >= static_cast<int>(items_.size())) {
        return {};
    }
    return QString::fromStdString(items_[static_cast<std::size_t>(row)].name);
}

QString TorrentListModel::infoHashAt(const int row) const
{
    if (row < 0 || row >= static_cast<int>(items_.size())) {
        return {};
    }
    return QString::fromStdString(items_[static_cast<std::size_t>(row)].info_hash.v1_hex);
}

int TorrentListModel::stateAt(const int row) const
{
    if (row < 0 || row >= static_cast<int>(items_.size())) {
        return -1;
    }
    return static_cast<int>(items_[static_cast<std::size_t>(row)].state);
}

} // namespace torrex::models
