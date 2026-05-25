import QtQuick
import QtQuick.Controls.Basic
import Torrin

// Circular icon/text action (Telegram header style).
ToolButton {
    id: root
    implicitWidth: 40
    implicitHeight: 40
    padding: 0

    property bool filled: false

    background: Rectangle {
        radius: width / 2
        color: {
            if (!root.enabled)
                return "transparent"
            if (root.pressed)
                return Theme.accentPressed
            if (root.hovered)
                return root.filled ? Theme.accent : Theme.hover
            return root.filled ? Theme.accent : "transparent"
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    contentItem: Text {
        text: root.text
        font.pixelSize: root.filled ? Theme.fontBody : Theme.fontHeadline
        font.weight: root.filled ? Font.DemiBold : Font.Normal
        color: {
            if (!root.enabled)
                return Theme.textMuted
            return root.filled ? Theme.textOnAccent : Theme.textPrimary
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
