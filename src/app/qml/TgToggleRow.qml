import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

// Settings row: label + switch (avoids broken CheckBox PNG assets).
RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacingMd

    property string text: ""
    property bool checked: false

    signal toggled(bool checked)

    Label {
        text: root.text
        font.pixelSize: Theme.fontBody
        color: Theme.textPrimary
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    TgSwitch {
        checked: root.checked
        onToggled: function(on) { root.toggled(on) }
    }
}
