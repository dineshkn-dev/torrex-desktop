import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

// Files tab: sequential toggle + file list.
Item {
    id: root

    required property string infoHash
    required property bool sequential
    required property var fileEntries
    required property int dataRevision

    signal sequentialToggled(bool enabled)
    signal filePriorityChanged(int fileIndex, int priority)

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingMd

        DetailCard {
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMd

                Label {
                    text: qsTr("Download in order (sequential)")
                    font.pixelSize: Theme.fontBody
                    color: Theme.textPrimary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Switch {
                    checked: root.sequential
                    onToggled: root.sequentialToggled(checked)
                }
            }
        }

        Label {
            text: root.fileEntries.length > 0
                ? qsTr("%1 file(s)").arg(root.fileEntries.length)
                : qsTr("Waiting for metadata…")
            font.pixelSize: Theme.fontCaption
            color: Theme.textSecondary
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingXs
        }

        ListView {
            id: fileList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            spacing: Theme.spacingSm
            model: root.fileEntries

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: Rectangle {
                id: fileDelegate
                required property int index
                required property var modelData

                width: fileList.width
                implicitHeight: fileRow.implicitHeight + Theme.spacingMd * 2
                radius: Theme.radiusMedium
                color: Theme.surfaceCard
                border.color: Theme.border
                border.width: 1

                RowLayout {
                    id: fileRow
                    anchors.fill: parent
                    anchors.margins: Theme.spacingMd
                    spacing: Theme.spacingMd

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXs

                        Label {
                            text: fileDelegate.modelData.path
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontBody
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }

                        Label {
                            text: qsTr("%1% complete").arg(fileDelegate.modelData.progress)
                            color: Theme.textSecondary
                            font.pixelSize: Theme.fontCaption
                        }
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
                        property int lastPriority: fileDelegate.modelData.priority

                        Component.onCompleted: syncFromModel()

                        onActivated: {
                            const item = model[currentIndex]
                            if (item.value === lastPriority)
                                return
                            root.filePriorityChanged(
                                fileDelegate.modelData.fileIndex, item.value)
                            lastPriority = item.value
                        }

                        function syncFromModel() {
                            const p = fileDelegate.modelData.priority
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
