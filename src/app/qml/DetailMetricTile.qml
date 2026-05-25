import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 76
    radius: Theme.radiusMedium
    color: Theme.amoled ? Theme.amoledElevated : Theme.surfaceCard
    border.color: Theme.border
    border.width: 1

    property string caption: ""
    property string value: "—"
    property string hint: ""
    property color accent: Theme.accent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingXs

        Label {
            text: root.caption
            font.pixelSize: Theme.fontCaption
            color: Theme.textSecondary
            Layout.fillWidth: true
        }

        Label {
            text: root.value
            font.pixelSize: Theme.fontHeadline
            font.weight: Font.DemiBold
            color: Theme.textPrimary
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Label {
            visible: root.hint.length > 0
            text: root.hint
            font.pixelSize: Theme.fontCaption
            color: root.accent
            Layout.fillWidth: true
        }
    }

    Rectangle {
        width: 3
        height: parent.height * 0.5
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        radius: 2
        color: root.accent
        opacity: 0.85
    }
}
