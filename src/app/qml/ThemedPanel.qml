import QtQuick
import Torrin

// Bordered surface panel (use instead of Frame.background on native macOS style).
Item {
    id: root

    property int pad: 8

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        border.color: Theme.border
        radius: 8
    }

    default property alias content: contentArea.data

    Item {
        id: contentArea
        anchors.fill: parent
        anchors.margins: root.pad
    }
}
