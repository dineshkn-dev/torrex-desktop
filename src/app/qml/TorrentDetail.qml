import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Torrex

ScrollView {
    id: root
    required property int torrentRow
    clip: true

    readonly property var model: appController.torrents
    readonly property bool hasSelection: torrentRow >= 0 && torrentRow < model.count
    readonly property int dataRevision: model.dataRevision

    readonly property string detailName: {
        dataRevision
        return hasSelection ? model.nameAt(torrentRow) : ""
    }
    readonly property int detailState: {
        dataRevision
        return hasSelection ? model.stateAt(torrentRow) : -1
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

    ColumnLayout {
        width: root.availableWidth > 0 ? root.availableWidth : implicitWidth
        spacing: 16
        anchors.margins: 16

        Label {
            text: hasSelection ? detailName : qsTr("Select a torrent")
            font.pixelSize: 20
            font.bold: true
            color: Theme.textPrimary
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        TabBar {
            id: detailTabs
            Layout.fillWidth: true
            TabButton { text: qsTr("Overview") }
            TabButton { text: qsTr("Files") }
        }

        Loader {
            Layout.fillWidth: true
            Layout.preferredHeight: contentItem ? contentItem.implicitHeight : 120
            sourceComponent: detailTabs.currentIndex === 0 ? overviewPane : filesPane
        }

        Label {
            visible: !hasSelection
            text: qsTr("Choose a torrent from the list to see details.")
            color: Theme.textMuted
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    Component {
        id: overviewPane
        ColumnLayout {
            spacing: 10
            width: root.availableWidth > 0 ? root.availableWidth : implicitWidth

            DetailRow {
                label: qsTr("State")
                value: root.stateText(detailState)
            }
            DetailRow {
                label: qsTr("Progress")
                value: detailProgress + "%"
            }
            DetailRow {
                label: qsTr("Download")
                value: root.formatRate(detailDownloadRate)
            }
            DetailRow {
                label: qsTr("Upload")
                value: root.formatRate(detailUploadRate)
            }
            DetailRow {
                label: qsTr("Save folder")
                value: detailSavePath
                wrap: true
            }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: detailProgress
            }
        }
    }

    Component {
        id: filesPane
        Label {
            width: root.availableWidth > 0 ? root.availableWidth : implicitWidth
            text: qsTr("Per-file priorities and sequential download are planned for a later release.")
            color: Theme.textMuted
            wrapMode: Text.WordWrap
        }
    }

    function stateText(state) {
        switch (state) {
        case 0: return qsTr("Idle")
        case 1: return qsTr("Checking")
        case 2: return qsTr("Downloading")
        case 3: return qsTr("Seeding")
        case 4: return qsTr("Paused")
        case 5: return qsTr("Error")
        default: return qsTr("Unknown")
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

    component DetailRow: RowLayout {
        required property string label
        required property string value
        property bool wrap: false
        Layout.fillWidth: true
        spacing: 12

        Label {
            text: label
            color: Theme.textMuted
            Layout.preferredWidth: 100
        }
        Label {
            text: value
            color: Theme.textPrimary
            wrapMode: wrap ? Text.Wrap : Text.NoWrap
            elide: wrap ? Text.ElideNone : Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
