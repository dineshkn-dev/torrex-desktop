import QtQuick
import Torrex

// Pure-QML toggle (no Qt Quick Controls style PNG assets).
Item {
    id: root
    implicitWidth: 46
    implicitHeight: 28

    property bool checked: false

    signal toggled(bool checked)

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.accent : Theme.border

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            width: 22
            height: 22
            radius: 11
            y: (parent.height - height) / 2
            x: root.checked ? parent.width - width - 3 : 3
            color: Theme.textOnAccent
            Behavior on x {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
