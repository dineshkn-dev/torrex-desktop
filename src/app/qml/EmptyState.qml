import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

ColumnLayout {
    id: root
    spacing: Theme.spacingLg
    width: parent ? Math.min(420, parent.width - Theme.spacingLg * 4) : implicitWidth

    property string title: qsTr("No torrents yet")
    property string subtitle: ""
    property bool showActions: true

    signal addMagnet()
    signal addTorrent()

    Label {
        text: parent.title
        font.pixelSize: Theme.fontTitle
        font.weight: Font.DemiBold
        color: Theme.textPrimary
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
    }

    Label {
        visible: parent.subtitle.length > 0
        text: parent.subtitle
        font.pixelSize: Theme.fontBody
        color: Theme.textSecondary
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: 360
        Layout.alignment: Qt.AlignHCenter
    }

    RowLayout {
        visible: parent.showActions
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.spacingMd

        TgButton {
            text: qsTr("Add magnet")
            primary: true
            onClicked: root.addMagnet()
        }
        TgButton {
            text: qsTr("Add .torrent")
            onClicked: root.addTorrent()
        }
    }
}
