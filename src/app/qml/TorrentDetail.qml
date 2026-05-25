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
    readonly property real detailDownloaded: {
        dataRevision
        return hasSelection ? model.downloadedAt(torrentRow) : 0
    }
    readonly property real detailTotal: {
        dataRevision
        return hasSelection ? model.totalSizeAt(torrentRow) : 0
    }
    readonly property real detailUploaded: {
        dataRevision
        return hasSelection ? model.uploadedTotalAt(torrentRow) : 0
    }
    readonly property int detailPeers: {
        dataRevision
        return hasSelection ? model.peersAt(torrentRow) : 0
    }
    readonly property int detailSeeds: {
        dataRevision
        return hasSelection ? model.seedsAt(torrentRow) : 0
    }
    readonly property int detailConnections: {
        dataRevision
        return hasSelection ? model.connectionsAt(torrentRow) : 0
    }
    readonly property int detailEta: {
        dataRevision
        return hasSelection ? model.etaSecondsAt(torrentRow) : -1
    }
    readonly property bool detailHasMetadata: {
        dataRevision
        return hasSelection && model.hasMetadataAt(torrentRow)
    }
    readonly property bool detailPaused: detailState === 4

    Rectangle {
        anchors.fill: parent
        color: Theme.windowBackground
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Hero header with accent glow
        Item {
            Layout.fillWidth: true
            implicitHeight: heroCol.implicitHeight + Theme.spacingXl * 2
            visible: root.hasSelection
            clip: true

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Theme.accentGlow(0.22) }
                    GradientStop { position: 0.55; color: Theme.accentGlow(0.06) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            ColumnLayout {
                id: heroCol
                anchors.fill: parent
                anchors.margins: Theme.spacingXl
                spacing: Theme.spacingLg

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingLg

                    DetailProgressRing {
                        size: 104
                        progress: root.detailProgress
                        ringColor: root.detailProgress >= 100 ? Theme.success : Theme.accent
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        Label {
                            text: root.detailName
                            font.pixelSize: Theme.fontTitle
                            font.weight: Font.DemiBold
                            color: Theme.textPrimary
                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            Layout.fillWidth: true
                        }

                        DetailStatusPill {
                            torrentState: root.detailState
                            uploadStopped: root.detailUploadStopped
                        }

                        Label {
                            text: Theme.formatBytes(root.detailDownloaded) + " / "
                                + Theme.formatBytes(root.detailTotal)
                            font.pixelSize: Theme.fontCaption
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm

                    DetailActionChip {
                        glyph: "❚❚"
                        text: qsTr("Pause")
                        enabled: root.hasSelection && !root.detailPaused
                        onClicked: appController.pauseTorrent(root.detailInfoHash)
                    }
                    DetailActionChip {
                        glyph: "▶"
                        text: qsTr("Resume")
                        enabled: root.hasSelection && root.detailPaused
                        onClicked: appController.resumeTorrent(root.detailInfoHash)
                    }
                    DetailActionChip {
                        glyph: "⊘"
                        text: qsTr("Stop seeding")
                        enabled: Theme.canStopSeeding(
                            root.detailState, root.detailProgress, root.detailUploadStopped)
                        onClicked: appController.stopSeeding(root.detailInfoHash)
                    }
                    DetailActionChip {
                        glyph: "↻"
                        text: qsTr("Resume seeding")
                        enabled: Theme.canResumeSeeding(
                            root.detailState, root.detailProgress, root.detailUploadStopped)
                        onClicked: appController.resumeSeeding(root.detailInfoHash)
                    }
                    DetailActionChip {
                        id: detailMoreChip
                        glyph: "⋯"
                        text: qsTr("More")
                        onClicked: detailMenu.popupAt(detailMoreChip, 0, detailMoreChip.height)

                        TgMenu {
                            id: detailMenu
                            MenuItem {
                                text: qsTr("Force recheck")
                                onTriggered: appController.forceRecheck(root.detailInfoHash)
                            }
                            MenuItem {
                                text: qsTr("Force reannounce")
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
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.divider
            visible: root.hasSelection
        }

        DetailSegmentBar {
            id: segmentBar
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingLg
            Layout.rightMargin: Theme.spacingLg
            Layout.topMargin: Theme.spacingMd
            Layout.bottomMargin: Theme.spacingSm
            visible: root.hasSelection
            tabs: [
                { title: qsTr("Overview") },
                { title: qsTr("Files") }
            ]
            onTabActivated: function(index) { segmentBar.currentIndex = index }
        }

        Item {
            id: contentHost
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Theme.spacingLg
            visible: root.hasSelection
            clip: true

            StackLayout {
                anchors.fill: parent
                currentIndex: segmentBar.currentIndex

                TorrentOverviewPane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    downloadRate: root.detailDownloadRate
                    uploadRate: root.detailUploadRate
                    savePath: root.detailSavePath
                    infoHash: root.detailInfoHash
                    progress: root.detailProgress
                    downloaded: root.detailDownloaded
                    total: root.detailTotal
                    uploaded: root.detailUploaded
                    peers: root.detailPeers
                    seeds: root.detailSeeds
                    connections: root.detailConnections
                    etaSeconds: root.detailEta
                    torrentState: root.detailState
                    paused: root.detailPaused
                    sequential: root.detailSequential
                    hasMetadata: root.detailHasMetadata
                    onSequentialToggled: function(enabled) {
                        appController.setTorrentSequentialDownload(root.detailInfoHash, enabled)
                    }
                }

                TorrentFilesPane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    infoHash: root.detailInfoHash
                    fileEntries: root.detailFileEntries
                    dataRevision: root.dataRevision
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
}
