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
    property string heading: ""
    property string message: ""
    property string okText: qsTr("OK")
    property string cancelText: qsTr("Cancel")

    signal accepted()
    signal rejected()

    width: 400
    implicitHeight: contentLayout.implicitHeight + 2 * padding

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
            Layout.alignment: Qt.AlignRight
            spacing: Theme.spacingSm

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
