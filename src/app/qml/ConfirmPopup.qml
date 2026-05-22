import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

Popup {
    id: root
    modal: true
    focus: true
    dim: true
    padding: Theme.spacingLg
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    transformOrigin: Item.Center
    property string heading: ""
    property string message: ""
    property string okText: qsTr("OK")
    property string cancelText: qsTr("Cancel")

    signal accepted()
    signal rejected()

    width: {
        const host = parent
        if (!host)
            return 420
        return Math.min(420, Math.max(280, host.width - Theme.sheetMargin * 2))
    }
    implicitHeight: contentLayout.implicitHeight + 2 * padding

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "opacity"
                from: 0
                to: 1
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: root
                property: "scale"
                from: Theme.sheetEnterScale
                to: 1
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "opacity"
                to: 0
                duration: Theme.animFast
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: root
                property: "scale"
                to: Theme.sheetEnterScale
                duration: Theme.animNormal
                easing.type: Easing.InCubic
            }
        }
    }

    background: Rectangle {
        color: Theme.surface
        border.color: Theme.border
        radius: Theme.radiusLarge
    }

    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.padding
        spacing: Theme.spacingMd

        Label {
            text: root.heading
            font.pixelSize: Theme.fontHeadline
            font.weight: Font.DemiBold
            color: Theme.textPrimary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            text: root.message
            wrapMode: Text.WordWrap
            color: Theme.textSecondary
            font.pixelSize: Theme.fontBody
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Item { Layout.fillWidth: true }

            TgButton {
                text: root.cancelText
                onClicked: {
                    root.rejected()
                    root.close()
                }
            }
            TgButton {
                text: root.okText
                primary: true
                onClicked: {
                    root.accepted()
                    root.close()
                }
            }
        }
    }
}
