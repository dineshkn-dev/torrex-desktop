import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import Torrex

Popup {
    id: root
    modal: true
    focus: true
    dim: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0
    width: 480
    anchors.centerIn: Overlay.overlay ? Overlay.overlay : parent

    background: Rectangle {
        radius: Theme.radiusLarge
        color: Theme.sidebarBackground
        border.color: Theme.border
        border.width: 1
    }

    function pathToFolderUrl(path) {
        if (!path)
            return ""
        if (path.indexOf("file://") === 0)
            return path
        return "file://" + path
    }

    function submit() {
        const uri = magnetField.text.trim()
        if (uri === "")
            return
        appController.addMagnetUri(uri, downloadPathField.text)
        magnetField.text = ""
        root.close()
    }

    onOpened: downloadPathField.text = appController.defaultDownloadFolder

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.spacingLg
            spacing: Theme.spacingMd

            Label {
                text: qsTr("Add magnet link")
                font.pixelSize: Theme.fontTitle
                font.weight: Font.DemiBold
                color: Theme.textPrimary
            }

            Item { Layout.fillWidth: true }

            TgIconButton {
                text: "✕"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Close")
                onClicked: root.close()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.divider
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.spacingLg
            spacing: Theme.spacingMd

            Label {
                text: qsTr("Paste a magnet URI")
                color: Theme.textSecondary
                font.pixelSize: Theme.fontCaption
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            TgTextField {
                id: magnetField
                placeholderText: qsTr("magnet:?xt=urn:btih:…")
                Layout.fillWidth: true
                selectByMouse: true
            }
            Label {
                text: qsTr("Download folder")
                color: Theme.textSecondary
                font.pixelSize: Theme.fontCaption
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm
                TgTextField {
                    id: downloadPathField
                    Layout.fillWidth: true
                    selectByMouse: true
                    placeholderText: qsTr("Folder path…")
                }
                TgButton {
                    text: qsTr("Browse")
                    onClicked: {
                        folderDialog.currentFolder = pathToFolderUrl(downloadPathField.text)
                        folderDialog.open()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.divider
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.spacingLg
            spacing: Theme.spacingMd

            Item { Layout.fillWidth: true }

            TgButton {
                text: qsTr("Cancel")
                onClicked: root.close()
            }
            TgButton {
                text: qsTr("Add")
                primary: true
                onClicked: root.submit()
            }
        }
    }

    FolderDialog {
        id: folderDialog
        title: qsTr("Choose download folder")
        onAccepted: downloadPathField.text = selectedFolder.toLocalFile()
    }
}
