import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

Item {
    id: root
    clip: true

    required property real downloadRate
    required property real uploadRate
    readonly property string downloadRateText: Theme.formatRateForTorrent(
        root.downloadRate, root.paused)
    readonly property string uploadRateText: Theme.formatRateForTorrent(
        root.uploadRate, root.paused)
    required property string savePath
    required property string infoHash
    required property int progress
    required property real downloaded
    required property real total
    required property real uploaded
    required property int peers
    required property int seeds
    required property int connections
    required property int etaSeconds
    required property int torrentState
    required property bool paused
    required property bool sequential
    required property bool hasMetadata

    readonly property string etaDisplay: Theme.formatEtaForTorrent(
        root.etaSeconds, root.torrentState, root.progress, root.paused)
    readonly property bool stackSpeed: Theme.stackSpeedCards(root.width)
    readonly property int metricColumns: Theme.metricsGridColumns(root.width)
    readonly property bool narrowStorage: root.width > 0 && root.width < 400

    signal sequentialToggled(bool enabled)

    TgFormScroll {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            visible: !root.stackSpeed
            spacing: Theme.spacingMd

            DetailSpeedCard {
                direction: qsTr("Download")
                rateText: root.downloadRateText
                paused: root.paused
                tint: Theme.accent
            }
            DetailSpeedCard {
                direction: qsTr("Upload")
                rateText: root.uploadRateText
                paused: root.paused
                tint: Theme.success
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.stackSpeed
            spacing: Theme.spacingMd

            DetailSpeedCard {
                Layout.fillWidth: true
                direction: qsTr("Download")
                rateText: root.downloadRateText
                paused: root.paused
                tint: Theme.accent
            }
            DetailSpeedCard {
                Layout.fillWidth: true
                direction: qsTr("Upload")
                rateText: root.uploadRateText
                paused: root.paused
                tint: Theme.success
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: root.metricColumns
            columnSpacing: Theme.spacingMd
            rowSpacing: Theme.spacingMd

            DetailMetricTile {
                Layout.fillWidth: true
                caption: qsTr("Peers")
                value: root.peers > 0 ? String(root.peers) : qsTr("—")
                hint: root.connections > 0 ? qsTr("%1 connected").arg(root.connections) : ""
                accent: Theme.accent
            }
            DetailMetricTile {
                Layout.fillWidth: true
                caption: qsTr("Seeds")
                value: root.seeds > 0 ? String(root.seeds) : qsTr("—")
                accent: Theme.success
            }
            DetailMetricTile {
                Layout.fillWidth: true
                caption: qsTr("ETA")
                value: root.etaDisplay
                accent: Theme.warning
            }
            DetailMetricTile {
                Layout.fillWidth: true
                caption: qsTr("Ratio")
                value: Theme.formatRatio(root.uploaded, root.downloaded)
                accent: Theme.accentColors.violet
            }
        }

        DetailCard {
            title: qsTr("Progress")

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                ThemedProgressBar {
                    Layout.fillWidth: true
                    thick: true
                    from: 0
                    to: 100
                    value: root.progress
                }

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: Theme.formatBytes(root.downloaded) + " / " + Theme.formatBytes(root.total)
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    Label {
                        text: root.progress + "%"
                        font.pixelSize: Theme.fontCaption
                        color: Theme.textSecondary
                    }
                }
            }
        }

        DetailCard {
            title: qsTr("Options")

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMd

                Label {
                    text: qsTr("Sequential download")
                    font.pixelSize: Theme.fontBody
                    color: Theme.textPrimary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                TgSwitch {
                    checked: root.sequential
                    onToggled: function(on) { root.sequentialToggled(on) }
                }
            }
        }

        DetailCard {
            title: qsTr("Storage")

            DetailStatRow {
                label: qsTr("Save folder")
                value: root.savePath.length > 0 ? root.savePath : qsTr("—")
                wrapValue: true
            }

            RowLayout {
                Layout.fillWidth: true
                visible: !root.narrowStorage
                spacing: Theme.spacingSm
                DetailStatRow {
                    Layout.fillWidth: true
                    label: qsTr("Info hash")
                    value: Theme.shortInfoHash(root.infoHash)
                }
                TgButton {
                    text: qsTr("Copy")
                    onClicked: appController.copyText(root.infoHash)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: root.narrowStorage
                spacing: Theme.spacingSm
                DetailStatRow {
                    Layout.fillWidth: true
                    label: qsTr("Info hash")
                    value: Theme.shortInfoHash(root.infoHash)
                    wrapValue: true
                }
                TgButton {
                    Layout.fillWidth: true
                    text: qsTr("Copy info hash")
                    onClicked: appController.copyText(root.infoHash)
                }
            }

            DetailStatRow {
                label: qsTr("Metadata")
                value: root.hasMetadata ? qsTr("Ready") : qsTr("Fetching…")
            }
        }

        Item { Layout.fillHeight: true }
    }
}
