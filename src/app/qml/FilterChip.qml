import QtQuick
import QtQuick.Controls.Basic
import Torrin

ToolButton {
    id: root
    checkable: true
    checked: false
    property int chipPadding: 12
    implicitHeight: 30
    padding: chipPadding

    background: Rectangle {
        id: chipBg
        radius: height / 2
        color: {
            if (root.checked)
                return Theme.accent
            if (root.pressed)
                return Theme.accentGlow(0.18)
            if (root.hovered)
                return Theme.hover
            return Theme.accentGlow(0.06)
        }
        border.color: root.checked ? Theme.accentGlow(0.5) : Theme.border
        border.width: root.checked ? 0 : 1

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
        Behavior on border.width {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: root.checked
            color: Theme.accentGlow(0.22)
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
