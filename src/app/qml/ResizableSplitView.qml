import QtQuick
import QtQuick.Controls
import Torrin

// Horizontal split with draggable handle; clips children to pane bounds.
SplitView {
    id: root
    orientation: Qt.Horizontal
    clip: true

    property int listMinWidth: Theme.listMinWidth
    property int detailMinWidth: Theme.detailMinWidth

    handle: Rectangle {
        implicitWidth: 6
        color: hoverHandler.hovered ? Theme.border : Theme.divider

        HoverHandler {
            id: hoverHandler
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }
}
