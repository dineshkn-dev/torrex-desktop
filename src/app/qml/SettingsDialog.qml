import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import Torrex

Dialog {
    id: root
    title: qsTr("Settings")
    modal: true
    anchors.centerIn: parent
    width: 520
    height: Math.min(640, parent ? parent.height - 80 : 640)
    standardButtons: Dialog.Cancel | Dialog.Ok

    background: Rectangle {
        radius: Theme.radiusLarge
        color: Theme.surface
        border.color: Theme.border
    }

    onAboutToShow: appController.loadSessionSettingsFromStore()

    onAccepted: {
        appController.applySessionSettings()
        if (downloadFolderField.text.trim() !== "") {
            appController.defaultDownloadFolder = downloadFolderField.text.trim()
        }
    }

    contentItem: ColumnLayout {
        spacing: 12

        Label {
            text: qsTr("Default download folder")
            color: Theme.textMuted
            Layout.fillWidth: true
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            TextField {
                id: downloadFolderField
                Layout.fillWidth: true
                selectByMouse: true
                text: appController.defaultDownloadFolder
            }
            Button {
                text: qsTr("Browse…")
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
            text: qsTr("Bandwidth (0 = unlimited)")
            color: Theme.textMuted
            font.bold: true
            Layout.topMargin: 8
            Layout.fillWidth: true
        }
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: qsTr("Download")
                Layout.preferredWidth: 100
            }
            SpinBox {
                from: 0
                to: 102400
                stepSize: 100
                value: appController.downloadLimitKbps
                editable: true
                Layout.fillWidth: true
                onValueModified: appController.downloadLimitKbps = value
            }
            Label {
                text: qsTr("KB/s")
                color: Theme.textMuted
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: qsTr("Upload")
                Layout.preferredWidth: 100
            }
            SpinBox {
                from: 0
                to: 102400
                stepSize: 100
                value: appController.uploadLimitKbps
                editable: true
                Layout.fillWidth: true
                onValueModified: appController.uploadLimitKbps = value
            }
            Label {
                text: qsTr("KB/s")
                color: Theme.textMuted
            }
        }

        Label {
            text: qsTr("Network")
            color: Theme.textMuted
            font.bold: true
            Layout.topMargin: 8
            Layout.fillWidth: true
        }
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: qsTr("Listen port")
                Layout.preferredWidth: 100
            }
            SpinBox {
                from: 1024
                to: 65535
                value: appController.listenPort
                editable: true
                Layout.fillWidth: true
                onValueModified: appController.listenPort = value
            }
        }
        CheckBox {
            text: qsTr("UPnP port mapping")
            checked: appController.enableUpnp
            onToggled: appController.enableUpnp = checked
        }
        CheckBox {
            text: qsTr("NAT-PMP port mapping")
            checked: appController.enableNatPmp
            onToggled: appController.enableNatPmp = checked
        }
        CheckBox {
            text: qsTr("DHT")
            checked: appController.enableDht
            onToggled: appController.enableDht = checked
        }
        CheckBox {
            text: qsTr("Local peer discovery (LSD)")
            checked: appController.enableLsd
            onToggled: appController.enableLsd = checked
        }

        Label {
            text: qsTr("Proxy")
            color: Theme.textMuted
            font.bold: true
            Layout.topMargin: 8
            Layout.fillWidth: true
        }
        CheckBox {
            text: qsTr("Use proxy")
            checked: appController.proxyEnabled
            onToggled: appController.proxyEnabled = checked
        }
        RowLayout {
            Layout.fillWidth: true
            enabled: appController.proxyEnabled
            Label {
                text: qsTr("Type")
                Layout.preferredWidth: 100
            }
            ComboBox {
                Layout.fillWidth: true
                model: [
                    { label: qsTr("SOCKS5"), value: 1 },
                    { label: qsTr("HTTP"), value: 2 }
                ]
                textRole: "label"
                currentIndex: appController.proxyType === 2 ? 1 : 0
                onActivated: appController.proxyType = model[currentIndex].value
            }
        }
        RowLayout {
            Layout.fillWidth: true
            enabled: appController.proxyEnabled
            Label {
                text: qsTr("Host")
                Layout.preferredWidth: 100
            }
            TextField {
                Layout.fillWidth: true
                text: appController.proxyHost
                placeholderText: qsTr("127.0.0.1")
                onTextEdited: appController.proxyHost = text
            }
            SpinBox {
                from: 1
                to: 65535
                value: appController.proxyPort
                onValueModified: appController.proxyPort = value
            }
        }
        RowLayout {
            Layout.fillWidth: true
            enabled: appController.proxyEnabled
            Label {
                text: qsTr("User")
                Layout.preferredWidth: 100
            }
            TextField {
                Layout.fillWidth: true
                text: appController.proxyUsername
                onTextEdited: appController.proxyUsername = text
            }
        }
        RowLayout {
            Layout.fillWidth: true
            enabled: appController.proxyEnabled
            Label {
                text: qsTr("Password")
                Layout.preferredWidth: 100
            }
            TextField {
                Layout.fillWidth: true
                echoMode: TextInput.Password
                text: appController.proxyPassword
                onTextEdited: appController.proxyPassword = text
            }
        }

        Label {
            text: qsTr("Torrents restore automatically when you quit and reopen Torrex.")
            color: Theme.textMuted
            wrapMode: Text.WordWrap
            font.pixelSize: 11
            Layout.fillWidth: true
            Layout.topMargin: 4
        }
    }

    FolderDialog {
        id: settingsFolderDialog
        title: qsTr("Choose default download folder")
        onAccepted: downloadFolderField.text = selectedFolder.toLocalFile()
    }
}
