import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Torrex

ApplicationWindow {
    id: window
    width: 960
    height: 640
    minimumWidth: 720
    minimumHeight: 480
    visible: true
    title: qsTr("Torrex %1").arg(appController.version)
    color: Theme.windowBackground

    property bool hasTorrents: appController.torrents.count > 0
    property string selectedInfoHash: ""
    // TorrentState::Paused === 4 (see include/torrex/types.hpp)
    readonly property bool selectionPaused: selectedState === 4
    property int selectedState: -1

    Connections {
        target: Application.styleHints
        function onColorSchemeChanged() {
            // Re-apply window chrome when user toggles macOS Appearance (or Auto switches).
            window.color = Theme.windowBackground
        }
    }

    Component.onCompleted: appController.refreshTorrents()

    function localFilePath(fileUrl) {
        if (!fileUrl)
            return ""
        const path = fileUrl.toString()
        if (path.startsWith("file://"))
            return fileUrl.toLocalFile()
        return path
    }

    function confirmRemove(infoHash, deleteFiles, torrentName) {
        removeConfirmDialog.infoHash = infoHash
        removeConfirmDialog.deleteFiles = deleteFiles
        removeConfirmDialog.torrentName = torrentName
        removeConfirmDialog.open()
    }

    Dialog {
        id: removeConfirmDialog
        title: removeConfirmDialog.deleteFiles
            ? qsTr("Remove and delete data?")
            : qsTr("Remove torrent?")
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Cancel | Dialog.Ok
        property string infoHash: ""
        property bool deleteFiles: false
        property string torrentName: ""

        onAccepted: appController.removeTorrent(infoHash, deleteFiles)

        contentItem: Label {
            wrapMode: Text.WordWrap
            width: Math.min(window.width * 0.6, 420)
            text: removeConfirmDialog.deleteFiles
                ? qsTr("Delete all downloaded files for \"%1\"? This cannot be undone.")
                      .arg(removeConfirmDialog.torrentName)
                : qsTr("Remove \"%1\" from Torrex? Downloaded files will stay on disk.")
                      .arg(removeConfirmDialog.torrentName)
        }
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            Label {
                text: qsTr("Torrex")
                font.bold: true
                font.pixelSize: 18
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Pause")
                enabled: selectedInfoHash !== "" && !selectionPaused
                onClicked: appController.pauseTorrent(selectedInfoHash)
            }
            Button {
                text: qsTr("Resume")
                enabled: selectedInfoHash !== "" && selectionPaused
                onClicked: appController.resumeTorrent(selectedInfoHash)
            }
            Button {
                text: qsTr("Remove")
                enabled: selectedInfoHash !== ""
                onClicked: {
                    const row = torrentList.currentIndex
                    window.confirmRemove(
                        selectedInfoHash,
                        false,
                        row >= 0 ? appController.torrents.nameAt(row) : "")
                }
            }

            Button {
                text: qsTr("Add magnet")
                onClicked: magnetDialog.open()
            }
            Button {
                text: qsTr("Add .torrent")
                onClicked: torrentFileDialog.open()
            }
            ToolButton {
                text: qsTr("Refresh")
                display: AbstractButton.TextOnly
                onClicked: appController.refreshTorrents()
            }
        }
    }

    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Label {
                text: appController.statusMessage
                font.pixelSize: 12
                opacity: 0.75
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("%1 torrents").arg(appController.torrents.count)
                font.pixelSize: 12
            }
        }
    }

    property var folderPathTarget: null

    function pathToFolderUrl(path) {
        if (!path)
            return ""
        if (path.indexOf("file://") === 0)
            return path
        return "file://" + path
    }

    FolderDialog {
        id: downloadFolderDialog
        title: qsTr("Choose download folder")
        onAccepted: {
            if (folderPathTarget)
                folderPathTarget.text = selectedFolder.toLocalFile()
        }
    }

    Dialog {
        id: magnetDialog
        title: qsTr("Add magnet link")
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Cancel | Dialog.Ok
        onAboutToShow: downloadPathField.text = appController.defaultDownloadFolder
        onAccepted: {
            appController.addMagnetUri(magnetField.text.trim(), downloadPathField.text)
            magnetField.text = ""
        }

        contentItem: ColumnLayout {
            spacing: 12
            width: Math.min(window.width * 0.7, 520)

            Label {
                text: qsTr("Paste a magnet URI (magnet:?xt=urn:btih:…)")
                color: Theme.textMuted
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            TextField {
                id: magnetField
                placeholderText: qsTr("magnet:?...")
                Layout.fillWidth: true
                selectByMouse: true
            }

            Label {
                text: qsTr("Download folder")
                color: Theme.textMuted
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                TextField {
                    id: downloadPathField
                    Layout.fillWidth: true
                    selectByMouse: true
                    placeholderText: qsTr("Folder path…")
                }
                Button {
                    text: qsTr("Browse…")
                    onClicked: {
                        folderPathTarget = downloadPathField
                        downloadFolderDialog.currentFolder = pathToFolderUrl(downloadPathField.text)
                        downloadFolderDialog.open()
                    }
                }
            }
        }
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

    Dialog {
        id: torrentAddDialog
        title: qsTr("Add torrent")
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Cancel | Dialog.Ok
        property url torrentFile

        onAboutToShow: downloadPathFieldTorrent.text = appController.defaultDownloadFolder

        onAccepted: appController.addTorrentFile(torrentFile, downloadPathFieldTorrent.text)

        contentItem: ColumnLayout {
            spacing: 12
            width: Math.min(window.width * 0.7, 520)

            Label {
                text: qsTr("Torrent file")
                color: Theme.textMuted
            }
            Label {
                text: window.localFilePath(torrentAddDialog.torrentFile)
                wrapMode: Text.WrapAnywhere
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Download folder")
                color: Theme.textMuted
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                TextField {
                    id: downloadPathFieldTorrent
                    Layout.fillWidth: true
                    selectByMouse: true
                    placeholderText: qsTr("Folder path…")
                }
                Button {
                    text: qsTr("Browse…")
                    onClicked: {
                        folderPathTarget = downloadPathFieldTorrent
                        downloadFolderDialog.currentFolder =
                            pathToFolderUrl(downloadPathFieldTorrent.text)
                        downloadFolderDialog.open()
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 16

        // Empty state (ListView cannot show overlay children reliably)
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(420, parent.width)
            spacing: 16
            visible: !window.hasTorrents

            Label {
                text: qsTr("No torrents yet")
                font.pixelSize: 22
                font.bold: true
                color: Theme.textPrimary
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Add a magnet link or open a .torrent file to start downloading.")
                color: Theme.textMuted
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Button {
                    text: qsTr("Add magnet")
                    highlighted: true
                    onClicked: magnetDialog.open()
                }
                Button {
                    text: qsTr("Add .torrent")
                    onClicked: torrentFileDialog.open()
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            visible: window.hasTorrents
            spacing: 12

            ThemedPanel {
                Layout.preferredWidth: 132
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 4

                    Label {
                        text: qsTr("Filter")
                        font.bold: true
                        color: Theme.textMuted
                        font.pixelSize: 11
                    }

                    Repeater {
                        model: ListModel {
                            ListElement { filterId: "all"; title: qsTr("All") }
                            ListElement { filterId: "downloading"; title: qsTr("Downloading") }
                            ListElement { filterId: "seeding"; title: qsTr("Seeding") }
                            ListElement { filterId: "paused"; title: qsTr("Paused") }
                        }
                        delegate: ItemDelegate {
                            Layout.fillWidth: true
                            text: title
                            highlighted: appController.torrents.activeFilter === filterId
                            onClicked: {
                                appController.torrents.setFilter(filterId)
                                if (torrentList.count > 0)
                                    torrentList.currentIndex = 0
                                else
                                    torrentList.currentIndex = -1
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            SplitView {
                id: mainSplit
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: Qt.Horizontal

                ThemedPanel {
                    SplitView.minimumWidth: 220
                    SplitView.preferredWidth: 300

                    ListView {
                        id: torrentList
                        anchors.fill: parent
                        model: appController.torrents
                        spacing: 4
                        clip: true

                        Connections {
                            target: appController.torrents
                            function onSnapshotsUpdated() {
                                torrentList.syncSelection()
                            }
                            function onActiveFilterChanged() {
                                if (torrentList.count > 0 && torrentList.currentIndex < 0)
                                    torrentList.currentIndex = 0
                            }
                        }

                        function syncSelection() {
                            if (currentIndex < 0 || currentIndex >= count) {
                                window.selectedInfoHash = ""
                                window.selectedState = -1
                                return
                            }
                            window.selectedInfoHash =
                                appController.torrents.infoHashAt(currentIndex)
                            window.selectedState =
                                appController.torrents.stateAt(currentIndex)
                        }

                        onCountChanged: {
                            if (count === 0) {
                                currentIndex = -1
                                syncSelection()
                            } else if (currentIndex < 0 || currentIndex >= count) {
                                currentIndex = 0
                            } else {
                                syncSelection()
                            }
                        }

                        onCurrentIndexChanged: syncSelection()

                        Component.onCompleted: {
                            if (count > 0 && currentIndex < 0)
                                currentIndex = 0
                        }

                        delegate: ItemDelegate {
                            id: row
                            width: torrentList.width
                            highlighted: torrentList.currentIndex === index
                            text: {
                                var line = name + " — " + progress + "%"
                                if (downloadRate > 0) {
                                    line += "  ↓ " + formatBytes(downloadRate) + "/s"
                                }
                                return line
                            }

                            function formatBytes(bytes) {
                                if (bytes < 1024) return bytes + " B"
                                if (bytes < 1024 * 1024)
                                    return (bytes / 1024).toFixed(1) + " KB"
                                return (bytes / (1024 * 1024)).toFixed(1) + " MB"
                            }

                            onClicked: torrentList.currentIndex = index

                            TapHandler {
                                acceptedButtons: Qt.RightButton
                                onTapped: rowMenu.open()
                            }

                            Menu {
                                id: rowMenu
                                MenuItem {
                                    text: qsTr("Pause")
                                    enabled: state !== 4
                                    onTriggered: appController.pauseTorrent(infoHash)
                                }
                                MenuItem {
                                    text: qsTr("Resume")
                                    enabled: state === 4
                                    onTriggered: appController.resumeTorrent(infoHash)
                                }
                                MenuSeparator {}
                                MenuItem {
                                    text: qsTr("Remove")
                                    onTriggered: window.confirmRemove(infoHash, false, name)
                                }
                                MenuItem {
                                    text: qsTr("Remove and delete data")
                                    onTriggered: window.confirmRemove(infoHash, true, name)
                                }
                            }
                        }
                    }
                }

                ThemedPanel {
                    SplitView.minimumWidth: 260
                    SplitView.fillWidth: true
                    pad: 0

                    TorrentDetail {
                        anchors.fill: parent
                        torrentRow: torrentList.currentIndex
                    }
                }
            }
        }
    }
}
