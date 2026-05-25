import QtQuick
import QtQuick.Controls.Basic
import Torrin

ToolButton {
    id: root
    checkable: true
    checked: false
    implicitHeight: 32
    padding: 12

    background: Rectangle {
        radius: 16
        color: root.checked ? Theme.accent : (root.hovered ? Theme.hover : "transparent")
        border.color: root.checked ? Theme.accent : Theme.border
        border.width: 1

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    contentItem: Text {
        text: root.text
        color: root.checked ? Theme.textOnAccent : Theme.textSecondary

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
        font.pixelSize: Theme.fontCaption
        font.weight: root.checked ? Font.DemiBold : Font.Normal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
