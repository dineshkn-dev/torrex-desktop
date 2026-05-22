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

    ColumnLayout {
        width: root.availableWidth > 0 ? root.availableWidth : implicitWidth
        spacing: 16
        anchors.margins: 16

        Label {
            text: hasSelection ? model.nameAt(torrentRow) : qsTr("Select a torrent")
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

        StackLayout {
            Layout.fillWidth: true
            currentIndex: detailTabs.currentIndex

            // Overview
            ColumnLayout {
                spacing: 10
                visible: hasSelection

                DetailRow {
                    label: qsTr("State")
                    value: hasSelection ? root.stateText(model.stateAt(torrentRow)) : ""
                }
                DetailRow {
                    label: qsTr("Progress")
                    value: hasSelection ? model.progressAt(torrentRow) + "%" : ""
                }
                DetailRow {
                    label: qsTr("Download")
                    value: hasSelection ? root.formatRate(model.downloadRateAt(torrentRow)) : ""
                }
                DetailRow {
                    label: qsTr("Upload")
                    value: hasSelection ? root.formatRate(model.uploadRateAt(torrentRow)) : ""
                }
                DetailRow {
                    label: qsTr("Save folder")
                    value: hasSelection ? model.savePathAt(torrentRow) : ""
                    wrap: true
                }

                ProgressBar {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: hasSelection ? model.progressAt(torrentRow) : 0
                }
            }

            // Files (phase 3 placeholder)
            Label {
                text: qsTr("Per-file priorities and sequential download are planned for a later release.")
                color: Theme.textMuted
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        Label {
            visible: !hasSelection
            text: qsTr("Choose a torrent from the list to see details.")
            color: Theme.textMuted
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
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
