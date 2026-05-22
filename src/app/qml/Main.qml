import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Torrex

ApplicationWindow {
    id: window
    width: 960
    height: 640
    minimumWidth: 720
    minimumHeight: 480
    visible: true
    title: qsTr("Torrex %1").arg(appController.version)
    color: Theme.windowBackground

    property bool hasTorrents: appController.torrents.count > 0

    Connections {
        target: Application.styleHints
        function onColorSchemeChanged() {
            // Re-apply window chrome when user toggles macOS Appearance (or Auto switches).
            window.color = Theme.windowBackground
        }
    }

    Component.onCompleted: appController.refreshTorrents()

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            Label {
                text: qsTr("Torrex")
                font.bold: true
                font.pixelSize: 18
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Add magnet")
                onClicked: magnetDialog.open()
            }
            Button {
                text: qsTr("Add .torrent")
                onClicked: torrentFileDialog.open()
            }
            ToolButton {
                text: qsTr("Refresh")
                display: AbstractButton.TextOnly
                onClicked: appController.refreshTorrents()
            }
        }
    }

    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Label {
                text: appController.statusMessage
                font.pixelSize: 12
                opacity: 0.75
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("%1 torrents").arg(appController.torrents.count)
                font.pixelSize: 12
            }
        }
    }

    Dialog {
        id: magnetDialog
        title: qsTr("Add magnet link")
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Cancel | Dialog.Ok
        onAccepted: {
            appController.addMagnetUri(magnetField.text.trim())
            magnetField.text = ""
        }

        contentItem: ColumnLayout {
            spacing: 12
            Label {
                text: qsTr("Paste a magnet URI (magnet:?xt=urn:btih:…)")
                color: Theme.textMuted
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            TextField {
                id: magnetField
                placeholderText: qsTr("magnet:?...")
                Layout.fillWidth: true
                selectByMouse: true
            }
        }
    }

    FileDialog {
        id: torrentFileDialog
        title: qsTr("Open torrent file")
        nameFilters: [qsTr("Torrent files (*.torrent)")]
        onAccepted: appController.addTorrentFile(selectedFile)
    }

    Item {
        anchors.fill: parent
        anchors.margins: 16

        // Empty state (ListView cannot show overlay children reliably)
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(420, parent.width)
            spacing: 16
            visible: !window.hasTorrents

            Label {
                text: qsTr("No torrents yet")
                font.pixelSize: 22
                font.bold: true
                color: Theme.textPrimary
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Add a magnet link or open a .torrent file to start downloading.")
                color: Theme.textMuted
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Button {
                    text: qsTr("Add magnet")
                    highlighted: true
                    onClicked: magnetDialog.open()
                }
                Button {
                    text: qsTr("Add .torrent")
                    onClicked: torrentFileDialog.open()
                }
            }
        }

        Frame {
            anchors.fill: parent
            visible: window.hasTorrents
            padding: 8
            background: Rectangle {
                color: Theme.surface
                border.color: Theme.border
                radius: 8
            }

            ListView {
                id: torrentList
                anchors.fill: parent
                model: appController.torrents
                spacing: 4
                clip: true

                delegate: ItemDelegate {
                    width: torrentList.width
                    text: name + " — " + progress + "%"
                }
            }
        }
    }
}
