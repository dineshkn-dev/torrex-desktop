import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

// Label + prominent value (detail pane stat cell).
ColumnLayout {
    id: root
    spacing: Theme.spacingXs
    Layout.fillWidth: true

    property string label: ""
    property string value: ""
    property bool wrapValue: false

    Label {
        text: root.label
        font.pixelSize: Theme.fontCaption
        color: Theme.textSecondary
        Layout.fillWidth: true
    }

    Label {
        text: root.value.length > 0 ? root.value : qsTr("—")
        font.pixelSize: Theme.fontStat
        font.weight: Font.DemiBold
        color: Theme.textPrimary
        wrapMode: root.wrapValue ? Text.Wrap : Text.NoWrap
        elide: root.wrapValue ? Text.ElideNone : Text.ElideRight
        Layout.fillWidth: true
    }
}
