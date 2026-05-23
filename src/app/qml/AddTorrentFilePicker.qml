import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

// File checklist shown before confirming a torrent/magnet add.
ColumnLayout {
    id: root
    spacing: Theme.spacingMd

    property string status: "idle"
    property string title: ""
    property string sizeText: ""
    property var fileRows: []
    property int fileListPreferredHeight: 280

    readonly property int colToggle: 46
    readonly property int colSize: 76
    readonly property int colType: 52

    signal selectionChanged()

    function field(obj, key, fallback) {
        if (obj === undefined || obj === null)
            return fallback
        if (key in obj)
            return obj[key]
        return fallback
    }

    function fileNameFromPath(path) {
        if (!path)
            return ""
        const slash = path.lastIndexOf("/")
        return slash >= 0 ? path.substring(slash + 1) : path
    }

    function fileTypeFromPath(path) {
        const name = root.fileNameFromPath(path)
        const dot = name.lastIndexOf(".")
        if (dot <= 0 || dot === name.length - 1)
            return qsTr("—")
        return name.substring(dot + 1).toUpperCase()
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

    function setRowWanted(index, wanted) {
        const rows = root.fileRows.slice()
        const entry = rows[index]
        rows[index] = {
            filePath: entry.filePath,
            fileIndex: entry.fileIndex,
            size: entry.size,
            sizeText: entry.sizeText,
            wanted: wanted
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
        Layout.bottomMargin: Theme.spacingXs
    }

    Label {
        text: root.status === "loading"
            ? qsTr("Loading file list from peers…")
            : root.status === "error"
                ? (appController.addPreviewErrorMessage.length > 0
                    ? appController.addPreviewErrorMessage
                    : qsTr("Could not load file list"))
                : root.fileRows.length > 0
                ? qsTr("%1 file(s) · %2 selected").arg(root.fileRows.length).arg(root.sizeText)
                : qsTr("No files to show yet")
        font.pixelSize: Theme.fontCaption
        color: Theme.textSecondary
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: tableColumn.implicitHeight
        visible: root.status === "ready" || root.status === "loading"
        radius: Theme.radiusMedium
        color: Theme.surfaceCard
        border.color: Theme.border
        border.width: 1
        clip: true

        Column {
            id: tableColumn
            width: parent.width

            Rectangle {
                id: headerRow
                width: parent.width
                height: 36
                color: Theme.hover

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingMd
                    anchors.rightMargin: Theme.spacingMd
                    spacing: Theme.spacingMd

                    Label {
                        text: qsTr("Download")
                        font.pixelSize: Theme.fontCaption
                        font.weight: Font.DemiBold
                        color: Theme.textSecondary
                        Layout.preferredWidth: root.colToggle
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        text: qsTr("Name")
                        font.pixelSize: Theme.fontCaption
                        font.weight: Font.DemiBold
                        color: Theme.textSecondary
                        Layout.fillWidth: true
                    }

                    Label {
                        text: qsTr("Size")
                        font.pixelSize: Theme.fontCaption
                        font.weight: Font.DemiBold
                        color: Theme.textSecondary
                        Layout.preferredWidth: root.colSize
                        horizontalAlignment: Text.AlignRight
                    }

                    Label {
                        text: qsTr("Type")
                        font.pixelSize: Theme.fontCaption
                        font.weight: Font.DemiBold
                        color: Theme.textSecondary
                        Layout.preferredWidth: root.colType
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.divider
            }

            TgScrollView {
                id: fileScroll
                width: parent.width
                height: Math.max(120, Math.min(380, root.fileListPreferredHeight))
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Column {
                    id: fileColumn
                    width: fileScroll.availableWidth > 0 ? fileScroll.availableWidth : fileScroll.width

                    Repeater {
                        model: root.fileRows

                        delegate: Item {
                            required property int index
                            required property var modelData

                            width: fileColumn.width
                            height: 44

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingMd
                                anchors.rightMargin: Theme.spacingMd
                                spacing: Theme.spacingMd

                                TgSwitch {
                                    checked: modelData.wanted
                                    enabled: root.status === "ready"
                                    onToggled: function(on) {
                                        root.setRowWanted(index, on)
                                    }
                                }

                                Label {
                                    id: nameLabel
                                    text: root.fileNameFromPath(modelData.filePath)
                                    color: Theme.textPrimary
                                    font.pixelSize: Theme.fontBody
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                    ToolTip.visible: nameHover.hovered && modelData.filePath.length > 0
                                    ToolTip.text: modelData.filePath

                                    HoverHandler {
                                        id: nameHover
                                    }
                                }

                                Label {
                                    text: modelData.sizeText
                                    color: Theme.textSecondary
                                    font.pixelSize: Theme.fontCaption
                                    Layout.preferredWidth: root.colSize
                                    horizontalAlignment: Text.AlignRight
                                }

                                Label {
                                    text: root.fileTypeFromPath(modelData.filePath)
                                    color: Theme.textSecondary
                                    font.pixelSize: Theme.fontCaption
                                    Layout.preferredWidth: root.colType
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 1
                                color: Theme.divider
                                visible: index < root.fileRows.length - 1
                            }
                        }
                    }
                }
            }
        }
    }
}
