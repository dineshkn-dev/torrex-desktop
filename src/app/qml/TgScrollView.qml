import QtQuick
import QtQuick.Controls.Basic
import Torrex

// Scroll area tuned for fast wheel + smooth inertial flick (Telegram-like).
ScrollView {
    id: root
    clip: true

    property int horizontalPolicy: ScrollBar.AlwaysOff

    function applyScrollFeel() {
        const flick = root.contentItem
        if (!flick || flick.flickDeceleration === undefined)
            return
        flick.flickDeceleration = Theme.flickDeceleration
        flick.maximumFlickVelocity = Theme.maxFlickVelocity
        if ("wheelScrollMultiplier" in flick)
            flick.wheelScrollMultiplier = Theme.wheelScrollMultiplier
        flick.pixelAligned = false
        flick.boundsBehavior = Flickable.StopAtBounds
        flick.interactive = true
    }

    Component.onCompleted: applyScrollFeel()
    onContentItemChanged: applyScrollFeel()

    ScrollBar.vertical: ScrollBar {
        id: verticalBar
        policy: ScrollBar.AsNeeded
        implicitWidth: 6

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
