import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Torrex

// Detail pane for the selected torrent (Overview / Files tabs).
Item {
    id: root
    anchors.fill: parent

    required property int torrentRow

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
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

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

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 160

            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                visible: hasSelection && detailTabs.currentIndex === 0

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

                Item { Layout.fillHeight: true }
            }

            Label {
                anchors.fill: parent
                visible: hasSelection && detailTabs.currentIndex === 1
                text: qsTr("Per-file priorities and sequential download are planned for a later release.")
                color: Theme.textMuted
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignTop
            }

            Label {
                anchors.centerIn: parent
                width: parent.width
                visible: !hasSelection
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Choose a torrent from the list to see details.")
                color: Theme.textMuted
                wrapMode: Text.WordWrap
            }
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
            text: value.length > 0 ? value : qsTr("—")
            color: Theme.textPrimary
            wrapMode: wrap ? Text.Wrap : Text.NoWrap
            elide: wrap ? Text.ElideNone : Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
