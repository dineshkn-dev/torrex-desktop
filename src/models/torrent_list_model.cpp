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
        {StateRole, "state"},
        {ProgressRole, "progress"},
        {DownloadRateRole, "downloadRate"},
        {UploadRateRole, "uploadRate"},
    };
}

void TorrentListModel::refresh()
{
    beginResetModel();
    items_ = session_.snapshots();
    endResetModel();
    emit countChanged();
}

} // namespace torrex::models
