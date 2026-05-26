import QtQuick
import Torrin

// ListView with rubber-band overshoot and balanced mouse / trackpad wheel scrolling.
ListView {
    id: root

    Component.onCompleted: Theme.applyFlickablePhysics(root)

    ScrollWheelHandler {}
}
