import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

// Left sidebar: filters, torrent list, status (Telegram chat-list style).
Item {
    id: root
    clip: true

    property bool filterHidesAll: false
    readonly property bool compactHeader: Theme.listPaneCompactHeader(root.width)
    property string selectedInfoHash: ""
    property int selectedState: -1
    readonly property int torrentCount: torrentList.count
    readonly property int currentIndex: torrentList.currentIndex

    signal confirmRemove(string infoHash, bool deleteFiles, string name)
    signal addMagnetRequested()
    signal addTorrentRequested()
    signal settingsRequested()

    function focusSearchField() {
        searchField.forceActiveFocus()
        searchField.selectAll()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.sidebarBackground
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingMd
            Layout.rightMargin: Theme.spacingSm
            Layout.topMargin: Theme.spacingMd
            Layout.bottomMargin: Theme.spacingSm
            spacing: Theme.spacingSm

            RowLayout {
                spacing: Theme.spacingSm
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: !root.compactHeader
                Layout.maximumWidth: root.compactHeader ? logoBlock.implicitWidth : -1

                TorrinLogo {
                    id: logoBlock
                    size: root.compactHeader ? 28 : 36
                }

                ColumnLayout {
                    visible: !root.compactHeader
                    spacing: 0

                    Label {
                        text: qsTr("Torrin")
                        font.pixelSize: Theme.fontTitle
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Label {
                        text: appController.version
                        font.pixelSize: Theme.fontCaption
                        color: Theme.textSecondary
                    }
                }
            }

            Item { Layout.fillWidth: true }

            TgIconButton {
                id: addTorrentButton
                text: "+"
                filled: true
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Add torrent")
                onClicked: addMenu.popupAt(addTorrentButton, 0, addTorrentButton.height)

                TgMenu {
                    id: addMenu
                    MenuItem {
                        text: qsTr("Magnet link")
                        onTriggered: root.addMagnetRequested()
                    }
                    MenuItem {
                        text: qsTr("Torrent file")
                        onTriggered: root.addTorrentRequested()
                    }
                }
            }

            TgIconButton {
                id: listActionsButton
                text: "⋯"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("List actions")
                onClicked: listActionsMenu.popupAt(listActionsButton, 0, listActionsButton.height)

                TgMenu {
                    id: listActionsMenu
                    MenuItem {
                        text: qsTr("Pause all")
                        onTriggered: appController.pauseAllTorrents()
                    }
                    MenuItem {
                        text: qsTr("Resume all")
                        onTriggered: appController.resumeAllTorrents()
                    }
                }
            }

            TgIconButton {
                glyph: "settings"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Settings")
                onClicked: root.settingsRequested()
            }
        }

        TgTextField {
            id: searchField
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingMd
            Layout.rightMargin: Theme.spacingMd
            Layout.bottomMargin: Theme.spacingXs
            placeholderText: qsTr("Search torrents…")
            text: appController.torrents.searchQuery
            onTextChanged: {
                if (text !== appController.torrents.searchQuery)
                    appController.torrents.searchQuery = text
            }
        }

        TgScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.leftMargin: Theme.spacingMd
            Layout.rightMargin: Theme.spacingMd
            Layout.bottomMargin: Theme.spacingXs
            horizontalPolicy: ScrollBar.AsNeeded
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOff
            }

            Row {
                id: sortRow
                height: parent.height
                spacing: Theme.spacingSm

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Sort")
                    font.pixelSize: Theme.fontCaption
                    color: Theme.textSecondary
                }

                TgTabButton {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Name")
                    checkable: false
                    padding: 10
                    onClicked: {
                        appController.torrents.sortRole = 0
                        appController.torrents.sortAscending = true
                    }
                }
                TgTabButton {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Progress")
                    checkable: false
                    padding: 10
                    onClicked: appController.torrents.sortRole = 1
                }
                TgTabButton {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Down")
                    checkable: false
                    padding: 10
                    onClicked: appController.torrents.sortRole = 2
                }
                TgTabButton {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Up")
                    checkable: false
                    padding: 10
                    onClicked: appController.torrents.sortRole = 3
                }
                TgTabButton {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("ETA")
                    checkable: false
                    padding: 10
                    onClicked: appController.torrents.sortRole = 4
                }

                TgIconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    text: appController.torrents.sortAscending ? "↑" : "↓"
                    ToolTip.visible: hovered
                    ToolTip.text: appController.torrents.sortAscending
                        ? qsTr("Ascending — click to reverse")
                        : qsTr("Descending — click to reverse")
                    onClicked: appController.torrents.sortAscending =
                        !appController.torrents.sortAscending
                }
            }
        }

        // Filter chips (horizontal scroll when narrow)
        TgScrollView {
            id: filterScroll
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.bottomMargin: Theme.spacingXs
            horizontalPolicy: ScrollBar.AsNeeded
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOff
            }

            Row {
                id: chipRow
                height: filterScroll.height
                spacing: Theme.spacingSm
                leftPadding: Theme.spacingMd
                rightPadding: Theme.spacingMd

                Repeater {
                    model: ListModel {
                        ListElement { filterId: "all"; title: qsTr("All") }
                        ListElement { filterId: "downloading"; title: qsTr("Downloading") }
                        ListElement { filterId: "seeding"; title: qsTr("Seeding") }
                        ListElement { filterId: "paused"; title: qsTr("Paused") }
                    }
                    delegate: FilterChip {
                        required property string filterId
                        required property string title
                        anchors.verticalCenter: parent.verticalCenter
                        text: title
                        checked: appController.torrents.activeFilter === filterId
                        onClicked: {
                            const savedHash = root.selectedInfoHash
                            appController.torrents.setFilter(filterId)
                            const row = appController.torrents.rowForInfoHash(savedHash)
                            if (row >= 0)
                                torrentList.currentIndex = row
                            else if (torrentList.count > 0)
                                torrentList.currentIndex = 0
                            else
                                torrentList.currentIndex = -1
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.divider
        }

        // List or empty filter message
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                anchors.centerIn: parent
                width: parent.width - Theme.spacingLg * 2
                horizontalAlignment: Text.AlignHCenter
                visible: root.filterHidesAll
                wrapMode: Text.WordWrap
                color: Theme.textSecondary
                font.pixelSize: Theme.fontBody
                text: appController.torrents.searchQuery.length > 0
                    ? qsTr("No torrents match your search.")
                    : qsTr("No torrents match this filter.")
            }

            TgListView {
                id: torrentList
                anchors.fill: parent
                model: appController.torrents
                clip: true
                visible: !root.filterHidesAll
                spacing: Theme.spacingXs
                cacheBuffer: Theme.rowHeight * 4
                reuseItems: true

                displaced: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: Theme.animNormal
                        easing.type: Easing.OutCubic
                    }
                }

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Theme.animFast
                        easing.type: Easing.OutCubic
                    }
                }

                remove: Transition {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: Theme.animFast
                        easing.type: Easing.InCubic
                    }
                }

                Connections {
                    target: appController.torrents
                    function onSnapshotsUpdated() {
                        torrentList.syncSelection()
                    }
                    function onActiveFilterChanged() {
                        if (torrentList.count > 0 && torrentList.currentIndex < 0)
                            torrentList.currentIndex = 0
                    }
                }

                function syncSelection() {
                    if (currentIndex < 0 || currentIndex >= count) {
                        root.selectedInfoHash = ""
                        root.selectedState = -1
                        return
                    }
                    root.selectedInfoHash = appController.torrents.infoHashAt(currentIndex)
                    root.selectedState = appController.torrents.stateAt(currentIndex)
                }

                onCountChanged: {
                    if (count === 0) {
                        currentIndex = -1
                        syncSelection()
                    } else if (currentIndex < 0 || currentIndex >= count) {
                        currentIndex = 0
                    } else {
                        syncSelection()
                    }
                }

                onCurrentIndexChanged: syncSelection()

                Component.onCompleted: {
                    if (count > 0 && currentIndex < 0)
                        currentIndex = 0
                }

                delegate: TorrentRow {
                    id: rowDelegate
                    required property int index

                    readonly property int _rev: appController.torrents.dataRevision

                    width: torrentList.width
                    rowIndex: index
                    infoHash: { void(_rev); return appController.torrents.infoHashAt(index) }
                    name: { void(_rev); return appController.torrents.nameAt(index) }
                    progress: { void(_rev); return appController.torrents.progressAt(index) }
                    state: { void(_rev); return appController.torrents.stateAt(index) }
                    uploadStopped: { void(_rev); return appController.torrents.uploadStoppedAt(index) }
                    downloadRate: { void(_rev); return appController.torrents.downloadRateAt(index) }
                    uploadRate: { void(_rev); return appController.torrents.uploadRateAt(index) }
                    etaSeconds: { void(_rev); return appController.torrents.etaSecondsAt(index) }
                    paused: { void(_rev); return appController.torrents.stateAt(index) === 4 }
                    selected: torrentList.currentIndex === index

                    onClicked: torrentList.currentIndex = index
                    onContextMenuRequested: function(menuX, menuY) {
                        rowMenu.popupAt(rowDelegate, menuX, menuY)
                    }

                    TgMenu {
                        id: rowMenu
                        MenuItem {
                            text: qsTr("Pause")
                            enabled: rowDelegate.state !== 4
                            onTriggered: appController.pauseTorrent(rowDelegate.infoHash)
                        }
                        MenuItem {
                            text: qsTr("Resume")
                            enabled: rowDelegate.state === 4
                            onTriggered: appController.resumeTorrent(rowDelegate.infoHash)
                        }
                        MenuItem {
                            text: qsTr("Stop seeding")
                            enabled: Theme.canStopSeeding(
                                rowDelegate.state, rowDelegate.progress, rowDelegate.uploadStopped)
                            onTriggered: appController.stopSeeding(rowDelegate.infoHash)
                        }
                        MenuItem {
                            text: qsTr("Resume seeding")
                            enabled: Theme.canResumeSeeding(
                                rowDelegate.state, rowDelegate.progress, rowDelegate.uploadStopped)
                            onTriggered: appController.resumeSeeding(rowDelegate.infoHash)
                        }
                        MenuItem {
                            text: qsTr("Reveal in Finder")
                            enabled: rowDelegate.infoHash.length > 0
                            onTriggered: appController.revealTorrentInFinder(rowDelegate.infoHash)
                        }
                        MenuItem {
                            text: qsTr("Copy magnet link")
                            enabled: rowDelegate.infoHash.length > 0
                            onTriggered: appController.copyMagnetForTorrent(rowDelegate.infoHash)
                        }
                        TgMenuSeparator {}
                        MenuItem {
                            text: qsTr("Force recheck")
                            enabled: rowDelegate.infoHash.length > 0
                            onTriggered: appController.forceRecheck(rowDelegate.infoHash)
                        }
                        MenuItem {
                            text: qsTr("Force reannounce")
                            enabled: rowDelegate.infoHash.length > 0
                            onTriggered: appController.forceReannounce(rowDelegate.infoHash)
                        }
                        TgMenuSeparator {}
                        MenuItem {
                            text: qsTr("Remove")
                            onTriggered: rowDelegate.confirmRemove(
                                rowDelegate.infoHash, false, rowDelegate.name)
                        }
                        MenuItem {
                            text: qsTr("Remove and delete data")
                            onTriggered: rowDelegate.confirmRemove(
                                rowDelegate.infoHash, true, rowDelegate.name)
                        }
                    }

                    function confirmRemove(hash, deleteFiles, torrentName) {
                        root.confirmRemove(hash, deleteFiles, torrentName)
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
            Layout.margins: Theme.spacingMd
            spacing: Theme.spacingSm

            Label {
                text: {
                    appController.torrents.dataRevision
                    const free = appController.downloadFolderFreeSpaceText()
                    const status = appController.statusMessage
                    if (free.length > 0 && status.length > 0)
                        return status + " · " + free
                    if (free.length > 0)
                        return free
                    return status
                }
                font.pixelSize: Theme.fontCaption
                color: Theme.textSecondary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("%1").arg(torrentList.count)
                font.pixelSize: Theme.fontCaption
                color: Theme.textSecondary
            }
        }
    }
}
