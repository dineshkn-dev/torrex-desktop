#pragma once

#include <torrex/session_manager.hpp>
#include <torrex/types.hpp>

#include <QAbstractListModel>

namespace torrex::models {

class TorrentListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        InfoHashRole,
        StateRole,
        ProgressRole,
        DownloadRateRole,
        UploadRateRole,
    };
    Q_ENUM(Roles)

    explicit TorrentListModel(SessionManager& session, QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE QString infoHashAt(int row) const;
    Q_INVOKABLE int stateAt(int row) const;
    Q_INVOKABLE QString nameAt(int row) const;

signals:
    void countChanged();
    void snapshotsUpdated();

private:
    SessionManager& session_;
    std::vector<TorrentSnapshot> items_;
};

} // namespace torrex::models
