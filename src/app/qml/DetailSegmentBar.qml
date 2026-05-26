import QtQuick
import QtQuick.Controls.Basic
import Torrin

// Segmented tab control — equal-width segments; width follows parent.
Item {
    id: root
    implicitHeight: 36

    property int currentIndex: 0
    property var tabs: []

    signal tabActivated(int index)

    readonly property int tabCount: tabs.length
    readonly property real segmentWidth: tabCount > 0 && width > 0
        ? (width - tabRow.spacing * Math.max(0, tabCount - 1)) / tabCount
        : 0

    Rectangle {
        anchors.fill: tabRow
        radius: Theme.radiusSmall
        color: Theme.amoled ? Theme.amoledElevated : Theme.hover
        border.color: Theme.border
        border.width: 1
    }

    Row {
        id: tabRow
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        spacing: Theme.spacingXs

        Repeater {
            model: root.tabs
            delegate: ToolButton {
                id: tabButton
                required property int index
                required property var modelData

                width: Math.max(0, root.segmentWidth)
                height: tabRow.height
                checkable: true
                checked: root.currentIndex === index
                onClicked: {
                    root.currentIndex = index
                    root.tabActivated(index)
                }

                background: Rectangle {
                    radius: Theme.radiusSmall - 2
                    color: {
                        if (tabButton.checked)
                            return Theme.accentGlow(0.35)
                        if (tabButton.hovered)
                            return Theme.accentGlow(0.12)
                        return "transparent"
                    }
                    border.color: tabButton.checked ? Theme.accentGlow(0.6) : "transparent"
                    border.width: 1

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animFast
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                contentItem: Text {
                    text: modelData.title
                    font.pixelSize: Theme.fontCaption
                    font.weight: tabButton.checked ? Font.DemiBold : Font.Normal
                    color: tabButton.checked ? Theme.textPrimary : Theme.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
    }
}
