import QtQuick
import QtQuick.Controls.Basic
import Torrin

ToolButton {
    id: root
    checkable: true
    implicitHeight: 34
    padding: 16

    background: Rectangle {
        radius: 17
        color: root.checked ? Theme.accent : (root.hovered ? Theme.hover : "transparent")
    }

    contentItem: Text {
        text: root.text
        font.pixelSize: Theme.fontCaption
        font.weight: root.checked ? Font.DemiBold : Font.Normal
        color: root.checked ? Theme.textOnAccent : Theme.textSecondary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
