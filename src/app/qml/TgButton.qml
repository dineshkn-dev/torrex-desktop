import QtQuick
import QtQuick.Controls.Basic
import Torrex

Button {
    id: root
    implicitHeight: 40
    padding: 16

    property bool primary: false

    contentItem: Text {
        text: root.text
        font.pixelSize: Theme.fontBody
        font.weight: root.primary ? Font.DemiBold : Font.Normal
        color: root.primary ? Theme.textOnAccent : Theme.accent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: Theme.radiusMedium
        color: {
            if (!root.enabled)
                return Theme.border
            if (root.pressed)
                return root.primary ? Theme.accentPressed : Theme.hover
            if (root.hovered)
                return root.primary ? Theme.accent : Theme.hover
            return root.primary ? Theme.accent : "transparent"
        }
        border.color: root.primary ? "transparent" : Theme.accent
        border.width: root.primary ? 0 : 1

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
}
