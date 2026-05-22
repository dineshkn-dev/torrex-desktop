import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Torrex

ApplicationWindow {
    id: window
    width: 960
    height: 640
    visible: true
    title: qsTr("Torrex %1").arg(appController.version)

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12

            Label {
                text: qsTr("Torrex")
                font.bold: true
                font.pixelSize: 18
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Refresh")
                onClicked: appController.refreshTorrents()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Label {
            text: qsTr("Add a magnet link or drop a .torrent file to get started.")
            color: Theme.textMuted
            font.pixelSize: 14
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                anchors.fill: parent
                anchors.margins: 8
                model: appController.torrents
                spacing: 8

                delegate: ItemDelegate {
                    width: ListView.view.width
                    text: name + " — " + progress + "%"
                }

                Label {
                    anchors.centerIn: parent
                    visible: appController.torrents.count === 0
                    text: qsTr("No torrents yet")
                    color: Theme.textMuted
                }
            }
        }
    }
}
