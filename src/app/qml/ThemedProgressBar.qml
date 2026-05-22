import QtQuick
import Torrex

// Simple progress bar (avoids Fusion style PNG assets that fail on some Qt builds).
Item {
    id: root

    property real from: 0
    property real to: 100
    property real value: 0

    implicitHeight: 8

    readonly property real ratio: {
        if (to <= from) {
            return 0
        }
        const v = Math.max(from, Math.min(to, value))
        return (v - from) / (to - from)
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.border

        Rectangle {
            height: parent.height
            width: Math.max(0, parent.width * root.ratio)
            radius: height / 2
            color: Theme.accent
        }
    }
}
