import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

Item {
    id: root

    required property string infoHash
    required property var fileEntries
    required property int dataRevision

    signal filePriorityChanged(int fileIndex, int priority)

    readonly property int fileCount: {
        const entries = root.fileEntries
        if (entries === undefined || entries === null)
            return 0
        return entries.length
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingMd

        Label {
            text: root.fileCount > 0
                ? qsTr("%1 files in this torrent").arg(root.fileCount)
                : qsTr("Waiting for metadata…")
            font.pixelSize: Theme.fontCaption
            color: Theme.textSecondary
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingXs
        }

        RowLayout {
            visible: root.fileCount > 0
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingMd
            Layout.rightMargin: Theme.spacingMd
            spacing: Theme.spacingMd

            Label {
                text: qsTr("File name")
                font.pixelSize: Theme.fontCaption
                font.weight: Font.DemiBold
                color: Theme.textSecondary
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Priority")
                font.pixelSize: Theme.fontCaption
                font.weight: Font.DemiBold
                color: Theme.textSecondary
                horizontalAlignment: Text.AlignHCenter
                Layout.minimumWidth: 76
                Layout.preferredWidth: 76
                Layout.maximumWidth: 76
            }
        }

        // ListView needs a parent Item with fillHeight in ColumnLayout (otherwise height = 0).
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: fileList
                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: Theme.flickDeceleration
                maximumFlickVelocity: Theme.maxFlickVelocity
                spacing: Theme.spacingSm
                model: root.fileEntries

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                }

                delegate: Rectangle {
                    id: fileDelegate
                    required property int index
                    required property var modelData

                    width: fileList.width
                    implicitHeight: fileCol.implicitHeight + Theme.spacingMd * 2
                    radius: Theme.radiusMedium
                    color: Theme.surfaceCard
                    border.color: Theme.border
                    border.width: 1

                    ColumnLayout {
                        id: fileCol
                        anchors.fill: parent
                        anchors.margins: Theme.spacingMd
                        spacing: Theme.spacingSm

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingMd

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacingXs

                                Label {
                                    text: fileDelegate.modelData["path"] ?? ""
                                    color: Theme.textPrimary
                                    font.pixelSize: Theme.fontBody
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                }

                                Label {
                                    text: {
                                        const sz = fileDelegate.modelData["size"] ?? 0
                                        const pct = fileDelegate.modelData["progress"] ?? 0
                                        return Theme.formatBytes(sz) + " · " + pct + "%"
                                    }
                                    color: Theme.textSecondary
                                    font.pixelSize: Theme.fontCaption
                                }
                            }

                            TgMenuPicker {
                                id: priorityPicker
                                compact: true
                                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                                Layout.minimumWidth: 76
                                Layout.preferredWidth: 76
                                Layout.maximumWidth: 76
                                property var priorityModel: [
                                    { label: qsTr("Skip"), value: 0 },
                                    { label: qsTr("Low"), value: 1 },
                                    { label: qsTr("Normal"), value: 4 },
                                    { label: qsTr("High"), value: 7 }
                                ]
                                model: priorityPicker.priorityModel
                                property int lastPriority: fileDelegate.modelData["priority"] ?? 4

                                Component.onCompleted: syncFromModel()

                                onActivated: function(pickIndex) {
                                    const item = priorityModel[pickIndex]
                                    if (item.value === lastPriority)
                                        return
                                    root.filePriorityChanged(
                                        fileDelegate.modelData["fileIndex"], item.value)
                                    lastPriority = item.value
                                }

                                function syncFromModel() {
                                    const p = fileDelegate.modelData["priority"]
                                    for (let i = 0; i < priorityModel.length; ++i) {
                                        if (priorityModel[i].value === p) {
                                            currentIndex = i
                                            lastPriority = p
                                            return
                                        }
                                    }
                                }

                                Connections {
                                    target: root
                                    function onDataRevisionChanged() {
                                        priorityPicker.syncFromModel()
                                    }
                                }
                            }
                        }

                        ThemedProgressBar {
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: fileDelegate.modelData["progress"] ?? 0
                        }
                    }
                }
            }
        }
    }
}
