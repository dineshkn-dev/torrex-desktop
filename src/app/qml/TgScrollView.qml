import QtQuick
import QtQuick.Controls.Basic
import Torrin

// Scroll area: rubber-band overshoot, smooth flick, tuned mouse / trackpad wheels.
ScrollView {
    id: root
    clip: true

    property int horizontalPolicy: ScrollBar.AlwaysOff

    function applyScrollFeel() {
        const flick = root.contentItem
        if (!flick || flick.flickDeceleration === undefined)
            return
        Theme.applyFlickablePhysics(flick)
    }

    Component.onCompleted: applyScrollFeel()
    onContentItemChanged: applyScrollFeel()

    ScrollWheelHandler {
        flickable: root.contentItem
    }

    ScrollBar.vertical: ScrollBar {
        id: verticalBar
        policy: ScrollBar.AsNeeded
        implicitWidth: 6

        background: Item { implicitWidth: 0 }

        contentItem: Rectangle {
            implicitWidth: 6
            radius: 3
            color: Theme.scrollBar
            opacity: verticalBar.active || verticalBar.pressed ? 0.9 : 0.45

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    ScrollBar.horizontal: ScrollBar {
        id: horizontalBar
        policy: root.horizontalPolicy
        implicitHeight: 6

        background: Item { implicitHeight: 0 }

        contentItem: Rectangle {
            implicitHeight: 6
            radius: 3
            color: Theme.scrollBar
            opacity: horizontalBar.active || horizontalBar.pressed ? 0.9 : 0.45

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
