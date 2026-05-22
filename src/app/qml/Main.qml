import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import Torrex

ApplicationWindow {
    id: window
    width: 1024
    height: 680
    minimumWidth: 800
    minimumHeight: 520
    visible: true
    title: torrexUiRev >= 2
        ? qsTr("Torrex %1").arg(appController.version)
        : qsTr("Torrex %1 (legacy UI)").arg(appController.version)
    color: Theme.windowBackground

    property bool hasTorrents: appController.torrents.totalCount > 0
    property bool filterHidesAllTorrents: hasTorrents && appController.torrents.count === 0

    property string _removeInfoHash: ""
    property bool _removeDeleteFiles: false
    Connections {
        target: Application.styleHints
        function onColorSchemeChanged() {
            window.color = Theme.windowBackground
        }
    }

    Component.onCompleted: appController.refreshTorrents()

    function confirmRemove(infoHash, deleteFiles, torrentName) {
        window._removeInfoHash = infoHash
        window._removeDeleteFiles = deleteFiles
        removeConfirmPopup.heading = deleteFiles
            ? qsTr("Remove and delete data?")
            : qsTr("Remove torrent?")
        removeConfirmPopup.message = deleteFiles
            ? qsTr("Delete all downloaded files for \"%1\"? This cannot be undone.")
                  .arg(torrentName)
            : qsTr("Remove \"%1\" from Torrex? Downloaded files will stay on disk.")
                  .arg(torrentName)
        removeConfirmPopup.open()
    }

    ConfirmPopup {
        id: removeConfirmPopup
        parent: window.contentItem
        anchors.centerIn: parent
        okText: qsTr("Remove")
        onAccepted: appController.removeTorrent(window._removeInfoHash, window._removeDeleteFiles)
    }

    SettingsDialog {
        id: settingsDialog
        parent: Overlay.overlay
    }

    NotificationBanner {
        parent: window.contentItem
    }

    DropArea {
        anchors.fill: parent
        keys: ["text/uri-list", "text/plain"]
        onDropped: function(drop) {
            if (drop.hasUrls) {
                appController.handleDroppedUrls(drop.urls)
                drop.acceptProposedAction()
            } else if (drop.hasText) {
                const text = drop.text.trim()
                if (text.startsWith("magnet:"))
                    appController.addMagnetUri(text)
            }
        }
    }

    MagnetAddDialog {
        id: magnetDialog
        parent: Overlay.overlay
    }

    TorrentAddDialog {
        id: torrentAddDialog
        parent: Overlay.overlay
    }

    FileDialog {
        id: torrentFileDialog
        title: qsTr("Open torrent file")
        nameFilters: [qsTr("Torrent files (*.torrent)")]
        onAccepted: {
            torrentAddDialog.torrentFile = selectedFile
            torrentAddDialog.open()
        }
    }

    Item {
        anchors.fill: parent

        EmptyState {
            anchors.centerIn: parent
            visible: !window.hasTorrents
            subtitle: qsTr("Add a magnet link, open a .torrent file, or drag one onto the window.")
            onAddMagnet: magnetDialog.open()
            onAddTorrent: torrentFileDialog.open()
        }

        RowLayout {
            anchors.fill: parent
            visible: window.hasTorrents
            spacing: 0

            TorrentListPane {
                id: listPane
                Layout.preferredWidth: Theme.listWidth
                Layout.fillHeight: true
                filterHidesAll: window.filterHidesAllTorrents
                onConfirmRemove: function(infoHash, deleteFiles, name) {
                    window.confirmRemove(infoHash, deleteFiles, name)
                }
                onAddMagnetRequested: magnetDialog.open()
                onAddTorrentRequested: torrentFileDialog.open()
                onSettingsRequested: settingsDialog.open()
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: Theme.divider
            }

            TorrentDetail {
                Layout.fillWidth: true
                Layout.fillHeight: true
                torrentRow: listPane.currentIndex
                windowRef: window
            }
        }
    }
}
