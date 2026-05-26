import QtQuick
import QtQuick.Layouts
import Torrin

// Elevated toolbar shell for list search, sort, and filters.
Rectangle {
    id: root
    radius: Theme.radiusLarge
    color: Theme.dark ? Theme.amoledSurfaceCard : Theme.surface
    border.color: Theme.border
    border.width: 1
    clip: true

    property alias contentInnerWidth: contentColumn.width
    default property alias content: contentColumn.data

    implicitHeight: contentColumn.implicitHeight + Theme.spacingMd * 2

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd
    }
}
