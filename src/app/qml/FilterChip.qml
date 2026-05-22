import QtQuick
import QtQuick.Controls.Basic
import Torrex

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
    }

    contentItem: Text {
        text: root.text
        color: root.checked ? Theme.textOnAccent : Theme.textSecondary
        font.pixelSize: Theme.fontCaption
        font.weight: root.checked ? Font.DemiBold : Font.Normal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
