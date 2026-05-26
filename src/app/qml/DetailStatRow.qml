import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacingMd

    property string label: ""
    property string value: ""
    property bool wrapValue: false

    Label {
        text: root.label
        font.pixelSize: Theme.fontBody
        color: Theme.textSecondary
        wrapMode: Text.WordWrap
        Layout.minimumWidth: 64
        Layout.preferredWidth: Theme.statLabelWidth(root.width)
        Layout.maximumWidth: Theme.statLabelWidth(root.width)
        Layout.alignment: Qt.AlignTop
    }

    Label {
        text: root.value.length > 0 ? root.value : qsTr("—")
        font.pixelSize: Theme.fontStat
        font.weight: Font.DemiBold
        color: Theme.textPrimary
        horizontalAlignment: Text.AlignRight
        wrapMode: root.wrapValue ? Text.Wrap : Text.NoWrap
        elide: root.wrapValue ? Text.ElideNone : Text.ElideRight
        Layout.fillWidth: true
    }
}
