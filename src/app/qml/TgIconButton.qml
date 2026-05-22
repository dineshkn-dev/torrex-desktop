import QtQuick
import QtQuick.Controls.Basic
import Torrex

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
            if (root.pressed)
                return Theme.accentPressed
            if (root.hovered)
                return root.filled ? Theme.accent : Theme.hover
            return root.filled ? Theme.accent : "transparent"
        }
    }

    contentItem: Text {
        text: root.text
        font.pixelSize: root.filled ? Theme.fontBody : Theme.fontHeadline
        font.weight: root.filled ? Font.DemiBold : Font.Normal
        color: root.filled ? Theme.textOnAccent : Theme.textPrimary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
