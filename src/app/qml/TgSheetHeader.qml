import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

RowLayout {
    id: root
    Layout.fillWidth: true
    Layout.margins: Theme.spacingLg
    spacing: Theme.spacingMd

    property string title: ""

    signal closeRequested()

    Label {
        text: root.title
        font.pixelSize: Theme.fontTitle
        font.weight: Font.DemiBold
        color: Theme.textPrimary
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    TgIconButton {
        text: "✕"
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Close")
        onClicked: root.closeRequested()
    }
}
