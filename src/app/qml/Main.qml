import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore
import Torrin

ApplicationWindow {
    id: window
    width: 1024
    height: 680
    minimumWidth: 800
    minimumHeight: 520
    visible: true
    title: qsTr("Torrin %1").arg(appController.version)
    color: Theme.windowBackground

    Behavior on color {
        ColorAnimation {
            duration: Theme.animSlow
            easing.type: Easing.OutCubic
        }
    }

    Settings {
        id: uiSettings
        category: "ui"
        property int listPaneWidth: Theme.listWidth
    }

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

    Connections {
        target: appController
        function onAppearanceChanged() {
            window.color = Theme.windowBackground
        }
    }

    Component.onCompleted: {
        appController.refreshTorrents()
        Qt.callLater(enforceSplitLayout)
    }

    onWidthChanged: Qt.callLater(enforceSplitLayout)

    Shortcut {
        sequences: [ StandardKey.Find ]
        context: Qt.ApplicationShortcut
        enabled: window.hasTorrents
        onActivated: listPane.focusSearchField()
    }

    Shortcut {
        sequence: "Space"
        context: Qt.ApplicationShortcut
        enabled: window.hasTorrents && listPane.selectedInfoHash.length > 0
        onActivated: appController.togglePauseResumeTorrent(listPane.selectedInfoHash)
    }

    Shortcut {
        sequences: [ StandardKey.Delete ]
        context: Qt.ApplicationShortcut
        enabled: window.hasTorrents && listPane.selectedInfoHash.length > 0
        onActivated: window.confirmRemove(
            listPane.selectedInfoHash, false, appController.torrents.nameAt(listPane.currentIndex))
    }

    function confirmRemove(infoHash, deleteFiles, torrentName) {
        window._removeInfoHash = infoHash
        window._removeDeleteFiles = deleteFiles
        removeConfirmPopup.heading = deleteFiles
            ? qsTr("Remove and delete data?")
            : qsTr("Remove torrent?")
        removeConfirmPopup.message = deleteFiles
            ? qsTr("Delete all downloaded files for \"%1\"? This cannot be undone.")
                  .arg(torrentName)
            : qsTr("Remove \"%1\" from Torrin? Downloaded files will stay on disk.")
                  .arg(torrentName)
        removeConfirmPopup.open()
    }

    function clampListPaneWidth(requested) {
        if (!splitHost || splitHost.width <= 0)
            return Math.round(Math.max(Theme.listMinWidth, Math.min(Theme.listMaxWidth, requested)))
        const maxW = Math.max(Theme.listMinWidth,
            Math.min(Theme.listMaxWidth, Math.floor(splitHost.width * 0.55)))
        const minDetail = splitHost.detailMinWidth + 12
        const capByWindow = Math.max(Theme.listMinWidth, splitHost.width - minDetail)
        return Math.round(Math.max(Theme.listMinWidth, Math.min(maxW, capByWindow, requested)))
    }

    function enforceSplitLayout() {
        if (!hasTorrents || !splitHost || splitHost.width <= 0)
            return
        const maxList = clampListPaneWidth(uiSettings.listPaneWidth)
        if (listPane.width > maxList + 1)
            listPane.SplitView.preferredWidth = maxList
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

        ResizableSplitView {
            id: splitHost
            anchors.fill: parent
            visible: window.hasTorrents

            onWidthChanged: Qt.callLater(window.enforceSplitLayout)

            TorrentListPane {
                id: listPane
                z: 0
                SplitView.minimumWidth: splitHost.listMinWidth
                SplitView.maximumWidth: window.clampListPaneWidth(Theme.listMaxWidth)
                SplitView.preferredWidth: window.clampListPaneWidth(uiSettings.listPaneWidth)
                SplitView.fillHeight: true
                filterHidesAll: window.filterHidesAllTorrents
                onConfirmRemove: function(infoHash, deleteFiles, name) {
                    window.confirmRemove(infoHash, deleteFiles, name)
                }
                onAddMagnetRequested: magnetDialog.open()
                onAddTorrentRequested: torrentFileDialog.open()
                onSettingsRequested: settingsDialog.open()

                onWidthChanged: {
                    if (width > 0 && Math.abs(width - uiSettings.listPaneWidth) > 2)
                        uiSettings.listPaneWidth = window.clampListPaneWidth(width)
                }
            }

            TorrentDetail {
                z: 1
                SplitView.fillWidth: true
                SplitView.minimumWidth: splitHost.detailMinWidth
                SplitView.fillHeight: true
                torrentRow: listPane.currentIndex
                windowRef: window

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: listPane.blurSearch()
                }
            }
        }
    }
}
