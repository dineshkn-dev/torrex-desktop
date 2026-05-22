import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

// File checklist shown before confirming a torrent/magnet add.
ColumnLayout {
    id: root
    spacing: Theme.spacingSm

    property string status: "idle"
    property string title: ""
    property string sizeText: ""
    property var fileRows: []
    property int fileListPreferredHeight: 240

    signal selectionChanged()

    // QVariantMap uses "path" — avoid item.path (conflicts with QML Path type).
    function field(obj, key, fallback) {
        if (obj === undefined || obj === null)
            return fallback
        if (key in obj)
            return obj[key]
        return fallback
    }

    function rowFromVariant(item, index) {
        return {
            filePath: String(field(item, "path", "")),
            fileIndex: Number(field(item, "fileIndex", index)),
            size: Number(field(item, "size", 0)),
            sizeText: String(field(item, "sizeText", "")),
            wanted: field(item, "wanted", true) !== false
        }
    }

    function syncFromController() {
        const source = appController.addPreviewFiles
        const rows = []
        for (let i = 0; i < source.length; ++i)
            rows.push(root.rowFromVariant(source[i], i))
        root.fileRows = rows
        root.updateSizeText()
    }

    function selectionPayload() {
        const out = []
        for (let i = 0; i < root.fileRows.length; ++i) {
            const row = root.fileRows[i]
            out.push({
                path: row.filePath,
                fileIndex: row.fileIndex,
                size: row.size,
                sizeText: row.sizeText,
                wanted: row.wanted
            })
        }
        return out
    }

    function setAllWanted(wanted) {
        const rows = []
        for (let i = 0; i < root.fileRows.length; ++i) {
            const row = root.fileRows[i]
            rows.push({
                filePath: row.filePath,
                fileIndex: row.fileIndex,
                size: row.size,
                sizeText: row.sizeText,
                wanted: wanted
            })
        }
        root.fileRows = rows
        root.updateSizeText()
    }

    function updateSizeText() {
        let total = 0
        for (let i = 0; i < root.fileRows.length; ++i) {
            if (root.fileRows[i].wanted)
                total += root.fileRows[i].size
        }
        let text = ""
        if (total < 1024)
            text = total + " B"
        else if (total < 1024 * 1024)
            text = (total / 1024).toFixed(1) + " KB"
        else if (total < 1024 * 1024 * 1024)
            text = (total / (1024 * 1024)).toFixed(1) + " MB"
        else
            text = (total / (1024 * 1024 * 1024)).toFixed(1) + " GB"
        root.sizeText = text
        root.selectionChanged()
    }

    Connections {
        target: appController
        function onAddPreviewChanged() {
            root.syncFromController()
        }
    }

    Component.onCompleted: syncFromController()

    Label {
        visible: root.title.length > 0
        text: root.title
        font.pixelSize: Theme.fontBody
        font.weight: Font.DemiBold
        color: Theme.textPrimary
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingSm

        Label {
            text: root.status === "loading"
                ? qsTr("Loading file list from peers…")
                : root.status === "error"
                    ? qsTr("Could not load file list")
                    : root.fileRows.length > 0
                    ? qsTr("%1 file(s) · %2 selected").arg(root.fileRows.length).arg(root.sizeText)
                    : qsTr("No files to show yet")
            font.pixelSize: Theme.fontCaption
            color: Theme.textSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Item { Layout.fillWidth: true }

            TgButton {
                text: qsTr("All")
                enabled: root.status === "ready" && root.fileRows.length > 0
                onClicked: root.setAllWanted(true)
            }
            TgButton {
                text: qsTr("None")
                enabled: root.status === "ready" && root.fileRows.length > 0
                onClicked: root.setAllWanted(false)
            }
        }
    }

    TgScrollView {
        id: fileScroll
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(160, Math.min(360, root.fileListPreferredHeight))
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Column {
            id: fileColumn
            width: fileScroll.availableWidth > 0 ? fileScroll.availableWidth : fileScroll.width
            spacing: Theme.spacingXs

            Repeater {
                model: root.fileRows

                delegate: Rectangle {
                    required property int index
                    required property var modelData

                    width: fileColumn.width
                    implicitHeight: rowLayout.implicitHeight + Theme.spacingMd * 2
                    radius: Theme.radiusMedium
                    color: Theme.surfaceCard
                    border.color: Theme.border
                    border.width: 1
                    visible: root.status === "ready" || root.status === "loading"

                    RowLayout {
                        id: rowLayout
                        anchors.fill: parent
                        anchors.margins: Theme.spacingMd
                        spacing: Theme.spacingMd

                        TgSwitch {
                            checked: modelData.wanted
                            enabled: root.status === "ready"
                            onToggled: function(on) {
                                const rows = root.fileRows.slice()
                                const entry = rows[index]
                                rows[index] = {
                                    filePath: entry.filePath,
                                    fileIndex: entry.fileIndex,
                                    size: entry.size,
                                    sizeText: entry.sizeText,
                                    wanted: on
                                }
                                root.fileRows = rows
                                root.updateSizeText()
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 80
                            spacing: 2

                            Label {
                                text: modelData.filePath
                                color: Theme.textPrimary
                                font.pixelSize: Theme.fontBody
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }

                            Label {
                                text: modelData.sizeText
                                color: Theme.textSecondary
                                font.pixelSize: Theme.fontCaption
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
