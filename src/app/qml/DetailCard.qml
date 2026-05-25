import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: inner.implicitHeight + Theme.spacingLg * 2
    radius: Theme.radiusMedium
    color: Theme.surfaceCard
    border.color: Theme.border
    border.width: 1

    property string title: ""
    default property alias contents: inner.data

    ColumnLayout {
        id: inner
        anchors.fill: parent
        anchors.margins: Theme.spacingLg
        spacing: Theme.spacingMd

        Label {
            visible: root.title.length > 0
            text: root.title
            font.pixelSize: Theme.fontCaption
            font.weight: Font.DemiBold
            color: Theme.textSecondary
            Layout.fillWidth: true
        }
    }
}
