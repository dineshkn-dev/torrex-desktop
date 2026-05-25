import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

Item {
    id: root

    required property int torrentRow
    property var windowRef: null

    readonly property var model: appController.torrents
    readonly property bool hasSelection: torrentRow >= 0 && torrentRow < model.count
    readonly property int dataRevision: model.dataRevision
    readonly property string detailInfoHash: {
        dataRevision
        return hasSelection ? model.infoHashAt(torrentRow) : ""
    }
    readonly property string detailName: {
        dataRevision
        return hasSelection ? model.nameAt(torrentRow) : ""
    }
    readonly property int detailState: {
        dataRevision
        return hasSelection ? model.stateAt(torrentRow) : -1
    }
    readonly property bool detailUploadStopped: {
        dataRevision
        return hasSelection && model.uploadStoppedAt(torrentRow)
    }
    readonly property int detailProgress: {
        dataRevision
        return hasSelection ? model.progressAt(torrentRow) : 0
    }
    readonly property string detailSavePath: {
        dataRevision
        return hasSelection ? model.savePathAt(torrentRow) : ""
    }
    readonly property real detailDownloadRate: {
        dataRevision
        return hasSelection ? model.downloadRateAt(torrentRow) : 0
    }
    readonly property real detailUploadRate: {
        dataRevision
        return hasSelection ? model.uploadRateAt(torrentRow) : 0
    }
    readonly property var detailFileEntries: {
        dataRevision
        return hasSelection ? model.fileEntriesAt(torrentRow) : []
    }
    readonly property bool detailSequential: {
        dataRevision
        return hasSelection && model.sequentialDownloadAt(torrentRow)
    }
    readonly property bool detailPaused: detailState === 4

    Rectangle {
        anchors.fill: parent
        color: Theme.windowBackground
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: headerCol.implicitHeight + Theme.spacingLg * 2
            color: Theme.surfaceCard
            visible: root.hasSelection

            ColumnLayout {
                id: headerCol
                anchors.fill: parent
                anchors.margins: Theme.spacingLg
                spacing: Theme.spacingMd

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingMd

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 120
                        spacing: Theme.spacingXs

                        Label {
                            text: root.detailName
                            font.pixelSize: Theme.fontHeadline
                            font.weight: Font.DemiBold
                            color: Theme.textPrimary
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: Theme.spacingSm
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: Theme.stateColor(root.detailState)
                            }
                            Label {
                                text: Theme.stateLabel(root.detailState, root.detailUploadStopped)
                                font.pixelSize: Theme.fontCaption
                                color: Theme.textSecondary
                            }
                            Label {
                                text: "·"
                                color: Theme.textSecondary
                                font.pixelSize: Theme.fontCaption
                            }
                            Label {
                                text: root.detailProgress + "%"
                                font.pixelSize: Theme.fontCaption
                                font.weight: Font.DemiBold
                                color: Theme.textPrimary
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignTop | Qt.AlignRight
                        Layout.minimumWidth: 132
                        spacing: Theme.spacingXs
                        TgIconButton {
                            text: "❚❚"
                            enabled: root.hasSelection && !root.detailPaused
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Pause")
                            onClicked: appController.pauseTorrent(root.detailInfoHash)
                        }
                        TgIconButton {
                            text: "▶"
                            enabled: root.hasSelection && root.detailPaused
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Resume")
                            onClicked: appController.resumeTorrent(root.detailInfoHash)
                        }
                        TgIconButton {
                            id: detailMoreButton
                            text: "⋯"
                            enabled: root.hasSelection
                            onClicked: detailMenu.popupAt(detailMoreButton, 0, detailMoreButton.height)

                            TgMenu {
                                id: detailMenu
                                MenuItem {
                                    text: qsTr("Stop seeding")
                                    enabled: Theme.canStopSeeding(
                                        root.detailState, root.detailProgress, root.detailUploadStopped)
                                    onTriggered: appController.stopSeeding(root.detailInfoHash)
                                }
                                MenuItem {
                                    text: qsTr("Resume seeding")
                                    enabled: Theme.canResumeSeeding(
                                        root.detailState, root.detailProgress, root.detailUploadStopped)
                                    onTriggered: appController.resumeSeeding(root.detailInfoHash)
                                }
                                TgMenuSeparator {}
                                MenuItem {
                                    text: qsTr("Force recheck")
                                    enabled: root.hasSelection
                                    onTriggered: appController.forceRecheck(root.detailInfoHash)
                                }
                                MenuItem {
                                    text: qsTr("Force reannounce")
                                    enabled: root.hasSelection
                                    onTriggered: appController.forceReannounce(root.detailInfoHash)
                                }
                                TgMenuSeparator {}
                                MenuItem {
                                    text: qsTr("Remove")
                                    onTriggered: {
                                        if (root.windowRef)
                                            root.windowRef.confirmRemove(
                                                root.detailInfoHash, false, root.detailName)
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Remove and delete data")
                                    onTriggered: {
                                        if (root.windowRef)
                                            root.windowRef.confirmRemove(
                                                root.detailInfoHash, true, root.detailName)
                                    }
                                }
                            }
                        }
                    }
                }

                ThemedProgressBar {
                    Layout.fillWidth: true
                    thick: true
                    from: 0
                    to: 100
                    value: root.detailProgress
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.divider
            visible: root.hasSelection
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingLg
            Layout.rightMargin: Theme.spacingLg
            Layout.topMargin: Theme.spacingMd
            Layout.bottomMargin: Theme.spacingSm
            spacing: Theme.spacingSm
            visible: root.hasSelection

            TgTabButton {
                text: qsTr("Overview")
                checked: tabBar.currentIndex === 0
                onClicked: tabBar.currentIndex = 0
            }
            TgTabButton {
                text: qsTr("Files")
                checked: tabBar.currentIndex === 1
                onClicked: tabBar.currentIndex = 1
            }
            Item { Layout.fillWidth: true }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.divider
            visible: root.hasSelection
        }

        Item {
            id: tabBar
            property int currentIndex: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Theme.spacingLg
            visible: root.hasSelection
            clip: true

            Loader {
                anchors.fill: parent
                sourceComponent: tabBar.currentIndex === 0 ? overviewPage : filesPage
            }

            Component {
                id: overviewPage
                TorrentOverviewPane {
                    downloadRateText: root.formatRate(root.detailDownloadRate)
                    uploadRateText: root.formatRate(root.detailUploadRate)
                    savePath: root.detailSavePath
                }
            }

            Component {
                id: filesPage
                TorrentFilesPane {
                    infoHash: root.detailInfoHash
                    sequential: root.detailSequential
                    fileEntries: root.detailFileEntries
                    dataRevision: root.dataRevision
                    onSequentialToggled: function(enabled) {
                        appController.setTorrentSequentialDownload(root.detailInfoHash, enabled)
                    }
                    onFilePriorityChanged: function(fileIndex, priority) {
                        appController.setTorrentFilePriority(
                            root.detailInfoHash, fileIndex, priority)
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !root.hasSelection

            EmptyState {
                anchors.centerIn: parent
                width: Math.min(420, parent.width - Theme.spacingLg * 4)
                title: qsTr("Select a torrent")
                subtitle: qsTr("Pick one from the list to see progress, files, and controls.")
                showActions: false
            }
        }
    }

    function formatRate(bytesPerSec) {
        if (bytesPerSec <= 0)
            return qsTr("—")
        if (bytesPerSec < 1024)
            return bytesPerSec + " B/s"
        if (bytesPerSec < 1024 * 1024)
            return (bytesPerSec / 1024).toFixed(1) + " KB/s"
        return (bytesPerSec / (1024 * 1024)).toFixed(1) + " MB/s"
    }
}
