import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

// Segmented sort control with sliding pill (indicator is overlaid, not in the Row).
Item {
    id: root
    implicitHeight: 38

    property int sortRole: 0
    property bool sortAscending: true

    signal sortRoleSelected(int role)
    signal sortDirectionToggled()

    readonly property var segments: [
        { role: 0, label: qsTr("Name") },
        { role: 1, label: qsTr("Date created") }
    ]

    readonly property int segmentCount: segments.length
    readonly property int trackInset: 3
    readonly property int selectedIndex: {
        for (let i = 0; i < segments.length; ++i) {
            if (segments[i].role === root.sortRole)
                return i
        }
        return 0
    }

    readonly property real segmentWidth: {
        if (segmentCount <= 0 || trackHost.width <= 0)
            return 0
        const inner = trackHost.width - trackInset * 2
        const gaps = trackRow.spacing * (segmentCount - 1)
        return Math.max(0, (inner - gaps) / segmentCount)
    }

    readonly property real indicatorX: trackInset + selectedIndex * (segmentWidth + trackRow.spacing)

    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacingSm

        Item {
            id: trackHost
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: Theme.dark ? Theme.amoledSurfaceCard : Theme.surfaceCard
                border.color: Theme.border
                border.width: 1
            }

            Rectangle {
                id: indicator
                z: 0
                y: trackInset
                height: parent.height - trackInset * 2
                width: root.segmentWidth
                x: root.indicatorX
                radius: 9
                color: Theme.accent
                opacity: 0.28
                border.color: Theme.accentGlow(0.65)
                border.width: 1
                visible: root.segmentWidth > 0

                Behavior on x {
                    NumberAnimation {
                        duration: Theme.animNormal
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: Theme.animNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Row {
                id: trackRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                spacing: Theme.spacingXs

                Repeater {
                    model: root.segments
                    delegate: ToolButton {
                        id: segButton
                        required property int index
                        required property var modelData

                        width: root.segmentWidth
                        height: trackRow.height
                        padding: 0
                        z: 1

                        readonly property bool active: root.sortRole === modelData.role

                        background: Item {}

                        contentItem: Text {
                            text: modelData.label
                            font.pixelSize: Theme.fontCaption
                            font.weight: segButton.active ? Font.DemiBold : Font.Normal
                            color: segButton.active ? Theme.textPrimary : Theme.textSecondary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideNone

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animFast
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        onClicked: root.sortRoleSelected(modelData.role)
                    }
                }
            }
        }

        ToolButton {
            id: dirButton
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            Layout.alignment: Qt.AlignVCenter
            padding: 0
            onClicked: root.sortDirectionToggled()

            background: Rectangle {
                radius: 12
                color: dirButton.pressed ? Theme.accentPressed
                    : (dirButton.hovered ? Theme.hover : Theme.accentGlow(0.1))
                border.color: Theme.accentGlow(dirButton.hovered ? 0.45 : 0.22)
                border.width: 1
            }

            contentItem: Text {
                text: root.sortAscending ? "↑" : "↓"
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: Theme.accent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            ToolTip.visible: hovered
            ToolTip.text: root.sortAscending
                ? qsTr("Ascending — tap to reverse")
                : qsTr("Descending — tap to reverse")
        }
    }
}
