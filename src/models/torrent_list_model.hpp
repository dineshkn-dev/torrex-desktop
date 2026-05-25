#pragma once

#include <torrin/session_manager.hpp>
#include <torrin/types.hpp>

#include <QAbstractListModel>
#include <QString>
#include <vector>

namespace torrin::models {

class TorrentListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY countChanged)
    Q_PROPERTY(QString activeFilter READ activeFilter NOTIFY activeFilterChanged)
    Q_PROPERTY(int dataRevision READ dataRevision NOTIFY dataRevisionChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        InfoHashRole,
        StateRole,
        ProgressRole,
        DownloadRateRole,
        UploadRateRole,
        SavePathRole,
    };
    Q_ENUM(Roles)

    explicit TorrentListModel(SessionManager& session, QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void setFilter(const QString& filter_id);
    [[nodiscard]] int totalCount() const { return static_cast<int>(items_.size()); }
    [[nodiscard]] QString activeFilter() const { return active_filter_; }
    Q_INVOKABLE int rowForInfoHash(const QString& info_hash_hex) const;
    [[nodiscard]] int dataRevision() const { return data_revision_; }

    Q_INVOKABLE QString infoHashAt(int row) const;
    Q_INVOKABLE QString nameAt(int row) const;
    Q_INVOKABLE int stateAt(int row) const;
    Q_INVOKABLE int progressAt(int row) const;
    Q_INVOKABLE QString savePathAt(int row) const;
    Q_INVOKABLE qint64 downloadRateAt(int row) const;
    Q_INVOKABLE qint64 uploadRateAt(int row) const;
    Q_INVOKABLE QStringList filePathsAt(int row) const;
    Q_INVOKABLE QVariantList fileEntriesAt(int row) const;
    Q_INVOKABLE bool sequentialDownloadAt(int row) const;

signals:
    void countChanged();
    void snapshotsUpdated();
    void activeFilterChanged();
    void dataRevisionChanged();

private:
    void rebuildFilteredRows();
    [[nodiscard]] const TorrentSnapshot* snapshotAt(int row) const;

    SessionManager& session_;
    std::vector<TorrentSnapshot> items_;
    std::vector<int> filtered_rows_;
    QString active_filter_ = QStringLiteral("all");
    int data_revision_ = 0;
};

} // namespace torrin::models
