import QtQuick
import QtQuick.Controls.Basic
import Torrex

// Modal sheet with Telegram-style open/close motion.
Popup {
    id: root
    modal: true
    focus: true
    dim: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    transformOrigin: Item.Center

    property int sheetWidth: Theme.sheetWidth
    property real heightRatio: Theme.sheetHeightRatio
    property int sheetMinHeight: Theme.sheetMinHeight
    property int sheetMaxHeight: Theme.sheetMaxHeight

    width: {
        const overlay = Overlay.overlay
        const host = overlay ? overlay : parent
        if (!host)
            return sheetWidth
        const maxW = host.width - Theme.sheetMargin * 2
        return Math.min(sheetWidth, Math.max(280, maxW))
    }
    height: {
        if (!parent)
            return sheetMinHeight
        const cap = parent.height - Theme.sheetMargin * 2
        return Math.min(sheetMaxHeight, Math.max(sheetMinHeight, parent.height * heightRatio), cap)
    }

    anchors.centerIn: Overlay.overlay ? Overlay.overlay : parent

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "opacity"
                from: 0
                to: 1
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: root
                property: "scale"
                from: Theme.sheetEnterScale
                to: 1
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "opacity"
                to: 0
                duration: Theme.animFast
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: root
                property: "scale"
                to: Theme.sheetEnterScale
                duration: Theme.animNormal
                easing.type: Easing.InCubic
            }
        }
    }

    background: Rectangle {
        radius: Theme.radiusLarge
        color: Theme.sidebarBackground
        border.color: Theme.border
        border.width: 1
    }
}
