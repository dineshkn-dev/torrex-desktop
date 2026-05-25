import QtQuick
import QtQuick.Controls.Basic
import Torrin

// Accent picker chip (settings appearance).
Item {
    id: root
    implicitWidth: 44
    implicitHeight: 44

    property string accentId: ""
    property color swatchColor: Theme.accent
    property bool selected: false

    signal activated(string accentId)

    Rectangle {
        anchors.centerIn: parent
        width: 36
        height: 36
        radius: 18
        color: root.swatchColor
        border.color: root.selected ? Theme.textPrimary : "transparent"
        border.width: root.selected ? 2 : 0

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated(root.accentId)
    }
}
