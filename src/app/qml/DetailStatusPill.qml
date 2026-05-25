import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

Rectangle {
    id: root
    implicitHeight: 26
    implicitWidth: row.implicitWidth + Theme.spacingMd * 2
    radius: 13
    color: Theme.accentGlow(0.18)
    border.color: Theme.accentGlow(0.45)
    border.width: 1

    property int torrentState: 0
    property bool uploadStopped: false

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacingXs

        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: Theme.stateColor(root.torrentState)
        }

        Label {
            text: Theme.stateLabel(root.torrentState, root.uploadStopped)
            font.pixelSize: Theme.fontCaption
            font.weight: Font.DemiBold
            color: Theme.textPrimary
        }
    }
}
