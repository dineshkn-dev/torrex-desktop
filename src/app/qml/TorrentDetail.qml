import QtQuick
import QtQuick.Controls.Basic
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
            currentIndex: 0

            TabButton {
                text: qsTr("Overview")
                width: implicitWidth + 20
                onClicked: detailTabs.currentIndex = 0
            }
            TabButton {
                text: qsTr("Files")
                width: implicitWidth + 20
                onClicked: detailTabs.currentIndex = 1
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 180
            visible: hasSelection
            clip: true

            StackLayout {
                id: tabStack
                anchors.fill: parent
                currentIndex: detailTabs.currentIndex

                ColumnLayout {
                    width: tabStack.width
                    height: tabStack.height
                    spacing: 10

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

                    ThemedProgressBar {
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: detailProgress
                    }

                    Item { Layout.fillHeight: true }
                }

                ColumnLayout {
                    width: tabStack.width
                    height: tabStack.height
                    spacing: 8

                    CheckBox {
                        text: qsTr("Download files in order (sequential)")
                        checked: root.detailSequential
                        enabled: root.hasSelection
                        onToggled: appController.setTorrentSequentialDownload(
                            root.detailInfoHash, checked)
                    }

                    Label {
                        text: detailFileEntries.length > 0
                            ? qsTr("%1 file(s)").arg(detailFileEntries.length)
                            : qsTr("Waiting for torrent metadata…")
                        color: Theme.textMuted
                        font.pixelSize: 12
                        Layout.fillWidth: true
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: detailFileEntries
                        spacing: 2

                        delegate: RowLayout {
                            width: ListView.view.width
                            spacing: 8

                            Label {
                                text: modelData.path
                                color: Theme.textPrimary
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                            Label {
                                text: modelData.progress + "%"
                                color: Theme.textMuted
                                font.pixelSize: 11
                            }
                            ComboBox {
                                id: priorityBox
                                Layout.preferredWidth: 100
                                textRole: "label"
                                model: [
                                    { label: qsTr("Skip"), value: 0 },
                                    { label: qsTr("Low"), value: 1 },
                                    { label: qsTr("Normal"), value: 4 },
                                    { label: qsTr("High"), value: 7 }
                                ]
                                property int lastPriority: modelData.priority

                                Component.onCompleted: syncFromModel()
                                onActivated: {
                                    const entry = model[currentIndex]
                                    if (entry.value === lastPriority)
                                        return
                                    appController.setTorrentFilePriority(
                                        root.detailInfoHash, modelData.fileIndex, entry.value)
                                    lastPriority = entry.value
                                }

                                function syncFromModel() {
                                    const p = modelData.priority
                                    for (let i = 0; i < model.length; ++i) {
                                        if (model[i].value === p) {
                                            currentIndex = i
                                            lastPriority = p
                                            return
                                        }
                                    }
                                }

                                Connections {
                                    target: root
                                    function onDataRevisionChanged() {
                                        priorityBox.syncFromModel()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Label {
            visible: !hasSelection
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("Choose a torrent from the list to see details.")
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
            text: value.length > 0 ? value : qsTr("—")
            color: Theme.textPrimary
            wrapMode: wrap ? Text.Wrap : Text.NoWrap
            elide: wrap ? Text.ElideNone : Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
