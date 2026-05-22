import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import Torrex

// Modal settings sheet (avoids native Dialog chrome and layout bleed-through).
TgSheet {
    id: root
    sheetMinHeight: 720
    sheetMaxHeight: 900

    onOpened: appController.loadSessionSettingsFromStore()

    function saveAndClose() {
        appController.applySessionSettings()
        const folder = downloadFolderField.text.trim()
        if (folder !== "")
            appController.defaultDownloadFolder = folder
        root.close()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TgSheetHeader {
            title: qsTr("Settings")
            onCloseRequested: root.close()
        }

        TgSheetDivider {}

        TgFormScroll {
            Layout.leftMargin: Theme.spacingLg
            Layout.rightMargin: Theme.spacingLg
            Layout.topMargin: Theme.spacingLg
            Layout.bottomMargin: Theme.spacingLg

            DetailCard {
                title: qsTr("Appearance")

                AppearanceSettingsSection {}
            }

            DetailCard {
                    title: qsTr("Downloads")

                    Label {
                        text: qsTr("Default folder")
                        font.pixelSize: Theme.fontCaption
                        color: Theme.textSecondary
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        TgTextField {
                            id: downloadFolderField
                            Layout.fillWidth: true
                            selectByMouse: true
                            text: appController.defaultDownloadFolder
                        }

                        TgButton {
                            text: qsTr("Browse")
                            onClicked: {
                                const path = downloadFolderField.text.trim()
                                if (path.length > 0) {
                                    settingsFolderDialog.currentFolder =
                                        path.indexOf("file://") === 0 ? path : ("file://" + path)
                                }
                                settingsFolderDialog.open()
                            }
                        }
                    }

                    Label {
                        text: qsTr("Torrents restore automatically when you quit and reopen Torrex.")
                        font.pixelSize: Theme.fontCaption
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.topMargin: Theme.spacingXs
                    }
                }

                DetailCard {
                    title: qsTr("Bandwidth")

                    Label {
                        text: qsTr("0 means unlimited")
                        font.pixelSize: Theme.fontCaption
                        color: Theme.textSecondary
                        Layout.fillWidth: true
                    }

                    SettingsNumberRow {
                        label: qsTr("Download")
                        value: appController.downloadLimitKbps
                        maximum: 102400
                        step: 100
                        suffix: qsTr("KB/s")
                        onValueModified: appController.downloadLimitKbps = newValue
                    }

                    SettingsNumberRow {
                        label: qsTr("Upload")
                        value: appController.uploadLimitKbps
                        maximum: 102400
                        step: 100
                        suffix: qsTr("KB/s")
                        onValueModified: appController.uploadLimitKbps = newValue
                    }
                }

                DetailCard {
                    title: qsTr("Network")

                    SettingsNumberRow {
                        label: qsTr("Listen port")
                        value: appController.listenPort
                        minimum: 1024
                        maximum: 65535
                        step: 1
                        onValueModified: appController.listenPort = newValue
                    }

                    TgToggleRow {
                        text: qsTr("UPnP port mapping")
                        checked: appController.enableUpnp
                        onToggled: appController.enableUpnp = checked
                    }
                    TgToggleRow {
                        text: qsTr("NAT-PMP port mapping")
                        checked: appController.enableNatPmp
                        onToggled: appController.enableNatPmp = checked
                    }
                    TgToggleRow {
                        text: qsTr("DHT")
                        checked: appController.enableDht
                        onToggled: appController.enableDht = checked
                    }
                    TgToggleRow {
                        text: qsTr("Local peer discovery (LSD)")
                        checked: appController.enableLsd
                        onToggled: appController.enableLsd = checked
                    }
                }

                DetailCard {
                    title: qsTr("Proxy")

                    TgToggleRow {
                        text: qsTr("Use proxy")
                        checked: appController.proxyEnabled
                        onToggled: appController.proxyEnabled = checked
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingMd
                        enabled: appController.proxyEnabled
                        opacity: appController.proxyEnabled ? 1 : 0.45

                        Label {
                            text: qsTr("Type")
                            font.pixelSize: Theme.fontCaption
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: Theme.spacingSm
                            TgTabButton {
                                text: qsTr("SOCKS5")
                                checked: appController.proxyType !== 2
                                onClicked: appController.proxyType = 1
                            }
                            TgTabButton {
                                text: qsTr("HTTP")
                                checked: appController.proxyType === 2
                                onClicked: appController.proxyType = 2
                            }
                            Item { Layout.fillWidth: true }
                        }

                        Label {
                            text: qsTr("Host and port")
                            font.pixelSize: Theme.fontCaption
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSm

                            TgTextField {
                                Layout.fillWidth: true
                                text: appController.proxyHost
                                placeholderText: qsTr("127.0.0.1")
                                onTextEdited: appController.proxyHost = text
                            }

                            TgTextField {
                                Layout.preferredWidth: 88
                                text: String(appController.proxyPort)
                                inputMethodHints: Qt.ImhDigitsOnly
                                horizontalAlignment: Text.AlignHCenter
                                onEditingFinished: {
                                    const p = parseInt(text, 10)
                                    if (!isNaN(p))
                                        appController.proxyPort = Math.max(1, Math.min(65535, p))
                                    text = String(appController.proxyPort)
                                }
                            }
                        }

                        Label {
                            text: qsTr("Authentication (optional)")
                            font.pixelSize: Theme.fontCaption
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                            Layout.topMargin: Theme.spacingXs
                        }

                        TgTextField {
                            Layout.fillWidth: true
                            text: appController.proxyUsername
                            placeholderText: qsTr("Username")
                            onTextEdited: appController.proxyUsername = text
                        }

                        TgTextField {
                            Layout.fillWidth: true
                            text: appController.proxyPassword
                            placeholderText: qsTr("Password")
                            echoMode: TextInput.Password
                            onTextEdited: appController.proxyPassword = text
                        }
                    }
                }
        }

        TgSheetDivider {}

        TgSheetFooter {
            primaryText: qsTr("Save")
            onCancelClicked: root.close()
            onPrimaryClicked: root.saveAndClose()
        }
    }

    FolderDialog {
        id: settingsFolderDialog
        title: qsTr("Choose default download folder")
        onAccepted: downloadFolderField.text = selectedFolder.toLocalFile()
    }
}
