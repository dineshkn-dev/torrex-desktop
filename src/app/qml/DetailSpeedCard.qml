import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

// Live transfer speed (rate text only).
Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 64
    radius: Theme.radiusMedium
    color: Theme.surfaceCard
    border.color: Theme.border
    border.width: 1

    property string direction: qsTr("Download")
    property string rateText: qsTr("—")
    property bool paused: false
    property color tint: Theme.accent

    readonly property bool active: !root.paused
        && root.rateText !== qsTr("—")
        && root.rateText.length > 0

    Rectangle {
        width: 3
        height: parent.height * 0.5
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        radius: 2
        color: root.tint
        opacity: root.active ? 0.9 : 0.35
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingXs

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Label {
                text: root.direction
                font.pixelSize: Theme.fontCaption
                font.weight: Font.DemiBold
                color: Theme.textSecondary
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: root.tint
                opacity: root.active ? 1 : 0.25

                SequentialAnimation on opacity {
                    running: root.active
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.55; to: 1; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1; to: 0.55; duration: 900; easing.type: Easing.InOutSine }
                }
            }
        }

        Label {
            text: root.rateText
            font.pixelSize: root.width > 0 && root.width < 120 ? Theme.fontBody : Theme.fontTitle
            font.weight: Font.DemiBold
            color: root.active ? root.tint : Theme.textSecondary
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
