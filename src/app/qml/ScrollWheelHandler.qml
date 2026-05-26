import QtQuick
import Torrin

// Tuned wheel scrolling (mouse vs trackpad). Parent must be a Flickable.
WheelHandler {
    id: root

    property Flickable flickable: (parent && parent.contentY !== undefined) ? parent : null

    enabled: flickable !== null
    target: flickable
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    orientation: Qt.Vertical | Qt.Horizontal
    blocking: true

    onWheel: function(event) {
        if (!flickable)
            return
        Theme.applyWheelScroll(flickable, event)
    }
}
