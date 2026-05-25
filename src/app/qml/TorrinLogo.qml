import QtQuick
import Torrin

// Scalable Torrin mark (SVG in Qt resources).
Item {
    id: root
    implicitWidth: size
    implicitHeight: size

    property int size: 32

    Image {
        anchors.centerIn: parent
        width: root.size
        height: root.size
        source: "qrc:/brand/torrin-mark.svg"
        sourceSize: Qt.size(root.size, root.size)
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
    }
}
