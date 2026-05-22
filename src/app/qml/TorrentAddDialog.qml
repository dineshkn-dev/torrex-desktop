import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import Torrex

TgSheet {
    id: root
    sheetMinHeight: 560
    sheetMaxHeight: 820

    property url torrentFile

    function pathToFolderUrl(path) {
        if (!path)
            return ""
        if (path.indexOf("file://") === 0)
            return path
        return "file://" + path
    }

    function submit() {
        if (!torrentFile)
            return
        if (appController.addPreviewStatus !== "ready")
            return
        const wantedCount = filePicker.fileRows.filter(function(row) { return row.wanted }).length
        if (wantedCount === 0)
            return
        appController.addTorrentFileWithSelection(
            torrentFile, downloadPathField.text, filePicker.selectionPayload())
        root.close()
    }

    onOpened: {
        downloadPathField.text = appController.defaultDownloadFolder
        appController.loadTorrentFilePreview(torrentFile)
        filePicker.syncFromController()
    }

    onClosed: appController.cancelAddPreview()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TgSheetHeader {
            title: qsTr("Add torrent")
            onCloseRequested: root.close()
        }

        TgSheetDivider {}

        TgFormScroll {
            Layout.leftMargin: Theme.spacingLg
            Layout.rightMargin: Theme.spacingLg
            Layout.topMargin: Theme.spacingLg
            Layout.bottomMargin: Theme.spacingLg

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

            AddTorrentFilePicker {
                id: filePicker
                Layout.fillWidth: true
                status: appController.addPreviewStatus
                title: appController.addPreviewTitle
            }
        }

        TgSheetDivider {}

        TgSheetFooter {
            primaryText: qsTr("Add")
            primaryEnabled: appController.addPreviewStatus === "ready"
                && filePicker.fileRows.some(function(row) { return row.wanted })
            onCancelClicked: root.close()
            onPrimaryClicked: root.submit()
        }
    }

    FolderDialog {
        id: folderDialog
        title: qsTr("Choose download folder")
        onAccepted: downloadPathField.text = selectedFolder.toLocalFile()
    }
}
