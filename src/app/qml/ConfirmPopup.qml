import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

// Modal confirm sheet (avoids Dialog implicitWidth binding loops).
Popup {
    id: root
    modal: true
    focus: true
    dim: true
    padding: 20
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    property string heading: ""
    property string message: ""
    property string okText: qsTr("OK")
    property string cancelText: qsTr("Cancel")

    signal accepted()
    signal rejected()

    width: 440
    implicitHeight: contentLayout.implicitHeight + 2 * padding

    background: Rectangle {
        color: Theme.surface
        border.color: Theme.border
        radius: 8
    }

    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.padding
        spacing: 16

        Label {
            text: root.heading
            font.bold: true
            font.pixelSize: 16
            color: Theme.textPrimary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            text: root.message
            wrapMode: Text.WordWrap
            color: Theme.textPrimary
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8

            Button {
                text: root.cancelText
                onClicked: {
                    root.rejected()
                    root.close()
                }
            }
            Button {
                text: root.okText
                highlighted: true
                onClicked: {
                    root.accepted()
                    root.close()
                }
            }
        }
    }
}
