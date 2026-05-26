import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

// Appearance block for Settings (theme + accent).
ColumnLayout {
    id: root
    spacing: Theme.spacingMd

    Label {
        text: qsTr("Theme")
        font.pixelSize: Theme.fontCaption
        color: Theme.textSecondary
        Layout.fillWidth: true
    }

    Flow {
        Layout.fillWidth: true
        spacing: Theme.spacingSm

        Repeater {
            model: [
                { mode: 0, label: qsTr("System") },
                { mode: 1, label: qsTr("Light") },
                { mode: 2, label: qsTr("Dark") }
            ]
            delegate: TgTabButton {
                required property int mode
                required property string label
                text: label
                checked: appController.appearanceMode === mode
                onClicked: appController.appearanceMode = mode
            }
        }
    }

    Label {
        text: qsTr("Accent color")
        font.pixelSize: Theme.fontCaption
        color: Theme.textSecondary
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacingSm
    }

    Flow {
        Layout.fillWidth: true
        spacing: Theme.spacingXs

        Repeater {
            model: Theme.accentOptions
            delegate: AccentColorSwatch {
                required property var modelData
                accentId: modelData.id
                swatchColor: modelData.color
                selected: appController.accentColorId === modelData.id
                onActivated: function(id) { appController.accentColorId = id }
            }
        }
    }
}
