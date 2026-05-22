import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

Item {
    id: root
    height: Theme.rowHeight

    property int rowIndex: -1
    property string name: ""
    property string infoHash: ""
    property int progress: 0
    property int state: 0
    property real downloadRate: 0
    property real uploadRate: 0
    property bool selected: false
    property bool hovered: false

    signal clicked()
    signal contextMenuRequested(real menuX, real menuY)

    Rectangle {
        anchors.fill: parent
        color: root.selected ? Theme.selectedMuted : (root.hovered ? Theme.hover : "transparent")
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.divider
        opacity: root.selected ? 0 : 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingLg
        anchors.rightMargin: Theme.spacingLg
        anchors.topMargin: Theme.spacingSm
        anchors.bottomMargin: Theme.spacingSm
        spacing: Theme.spacingXs

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingMd

            Rectangle {
                Layout.preferredWidth: 10
                Layout.preferredHeight: 10
                radius: 5
                color: Theme.stateColor(root.state)
            }

            Label {
                text: root.name
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
                color: Theme.textPrimary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                text: root.speedText
                visible: root.speedText.length > 0
                font.pixelSize: Theme.fontCaption
                color: Theme.textSecondary
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Label {
                text: root.metaLine
                font.pixelSize: Theme.fontCaption
                color: Theme.textSecondary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                text: root.progress + "%"
                font.pixelSize: Theme.fontCaption
                font.weight: Font.DemiBold
                color: Theme.stateColor(root.state)
            }
        }

        ThemedProgressBar {
            Layout.fillWidth: true
            from: 0
            to: 100
            value: root.progress
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton)
                root.clicked()
            else
                root.contextMenuRequested(mouse.x, mouse.y)
        }
    }

    readonly property string metaLine: Theme.stateLabel(root.state)

    readonly property string speedText: {
        if (root.downloadRate > 0)
            return formatBytes(root.downloadRate)
        if (root.uploadRate > 0)
            return formatBytes(root.uploadRate)
        return ""
    }

    function formatBytes(bytes) {
        if (bytes < 1024)
            return bytes + " B/s"
        if (bytes < 1024 * 1024)
            return (bytes / 1024).toFixed(1) + " KB/s"
        return (bytes / (1024 * 1024)).toFixed(1) + " MB/s"
    }
}
