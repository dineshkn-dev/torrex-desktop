import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

RowLayout {
    id: root
    Layout.fillWidth: true
    Layout.margins: Theme.spacingLg
    spacing: Theme.spacingMd

    property string cancelText: qsTr("Cancel")
    property string primaryText: qsTr("Save")
    property bool primaryEnabled: true

    signal cancelClicked()
    signal primaryClicked()

    Item { Layout.fillWidth: true }

    TgButton {
        text: root.cancelText
        onClicked: root.cancelClicked()
    }
    TgButton {
        text: root.primaryText
        primary: true
        enabled: root.primaryEnabled
        onClicked: root.primaryClicked()
    }
}
