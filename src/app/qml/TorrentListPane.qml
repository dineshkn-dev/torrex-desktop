import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrin

// Left sidebar: filters, torrent list, status (Telegram chat-list style).
Item {
    id: root
    implicitWidth: Theme.listWidth

    property bool filterHidesAll: false
    property string selectedInfoHash: ""
    property int selectedState: -1
    readonly property int torrentCount: torrentList.count
    readonly property int currentIndex: torrentList.currentIndex

    signal confirmRemove(string infoHash, bool deleteFiles, string name)
    signal addMagnetRequested()
    signal addTorrentRequested()
    signal settingsRequested()

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

            ColumnLayout {
                spacing: Theme.spacingXs
                Layout.alignment: Qt.AlignVCenter

                RowLayout {
                    spacing: Theme.spacingSm

                    TorrinLogo {
                        size: 36
                    }

                    ColumnLayout {
                        spacing: 0

                        Label {
                            text: qsTr("Torrin")
                            font.pixelSize: Theme.fontTitle
                            font.weight: Font.DemiBold
                            color: Theme.textPrimary
                        }

                        Label {
                            text: appController.version
                            font.pixelSize: Theme.fontCaption
                            color: Theme.textSecondary
                        }
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
                glyph: "settings"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Settings")
                onClicked: root.settingsRequested()
            }
        }

        // Filter chips (horizontal scroll when narrow)
        TgScrollView {
            id: filterScroll
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.bottomMargin: Theme.spacingXs
            horizontalPolicy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

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
                text: qsTr("No torrents match this filter.")
            }

            ListView {
                id: torrentList
                anchors.fill: parent
                model: appController.torrents
                clip: true
                visible: !root.filterHidesAll
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: Theme.flickDeceleration
                maximumFlickVelocity: Theme.maxFlickVelocity
                pixelAligned: false
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
                text: appController.statusMessage
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
