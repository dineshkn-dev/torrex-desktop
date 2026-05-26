import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import Torrin

// Horizontal split with draggable handle; clips children to pane bounds.
SplitView {
    id: root
    orientation: Qt.Horizontal
    clip: true

    property int defaultListWidth: Theme.listWidth
    property int listMinWidth: Theme.listMinWidth
    property int detailMinWidth: Theme.detailMinWidth

    // Keep handle hit target stable when panes resize.
    Component.onCompleted: resizeMode = SplitView.Stretch

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
