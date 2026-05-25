import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import Torrin

TgSheet {
    id: root
    sheetWidth: Theme.sheetWideWidth
    sheetMinHeight: 620
    sheetMaxHeight: 880

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
        if (appController.addPreviewStatus !== "ready")
            return
        const wantedCount = filePicker.fileRows.filter(function(row) { return row.wanted }).length
        if (wantedCount === 0)
            return
        appController.addMagnetWithSelection(uri, downloadPathField.text, filePicker.selectionPayload())
        magnetField.text = ""
        root.close()
    }

    function requestPreview() {
        const uri = magnetField.text.trim()
        if (!uri.startsWith("magnet:"))
            return
        appController.loadMagnetPreview(uri, downloadPathField.text)
    }

    Timer {
        id: previewDebounce
        interval: 600
        onTriggered: root.requestPreview()
    }

    onOpened: {
        downloadPathField.text = appController.defaultDownloadFolder
        if (magnetField.text.trim().startsWith("magnet:"))
            root.requestPreview()
    }

    onClosed: appController.cancelAddPreview()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TgSheetHeader {
            title: qsTr("Add magnet link")
            onCloseRequested: root.close()
        }

        TgSheetDivider {}

        TgFormScroll {
            Layout.leftMargin: Theme.sheetPadding
            Layout.rightMargin: Theme.sheetPadding
            Layout.topMargin: Theme.sheetPadding
            Layout.bottomMargin: Theme.sheetPadding
            contentSpacing: Theme.spacingXl

            Label {
                text: qsTr("Paste a magnet URI")
                color: Theme.textSecondary
                font.pixelSize: Theme.fontCaption
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.bottomMargin: -Theme.spacingSm
            }
            TgTextField {
                id: magnetField
                placeholderText: qsTr("magnet:?xt=urn:btih:…")
                Layout.fillWidth: true
                selectByMouse: true
                onTextChanged: previewDebounce.restart()
            }
            Label {
                text: qsTr("Download folder")
                color: Theme.textSecondary
                font.pixelSize: Theme.fontCaption
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacingSm
                Layout.bottomMargin: -Theme.spacingSm
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMd
                TgTextField {
                    id: downloadPathField
                    Layout.fillWidth: true
                    selectByMouse: true
                    placeholderText: qsTr("Folder path…")
                    onTextChanged: {
                        if (magnetField.text.trim().startsWith("magnet:"))
                            previewDebounce.restart()
                    }
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
                Layout.topMargin: Theme.spacingSm
                fileListPreferredHeight: 320
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
