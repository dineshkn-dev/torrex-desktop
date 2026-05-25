import QtQuick
import Torrin

Item {
    id: root

    property real from: 0
    property real to: 100
    property real value: 0
    property bool thick: false

    implicitHeight: thick ? Theme.progressThick : Theme.progressThin

    readonly property real ratio: {
        if (to <= from)
            return 0
        const v = Math.max(from, Math.min(to, value))
        return (v - from) / (to - from)
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.border

        Rectangle {
            height: parent.height
            width: Math.max(thick ? 4 : 2, parent.width * root.ratio)
            radius: height / 2
            color: root.value >= 100 ? Theme.success : Theme.accent

            Behavior on width {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
