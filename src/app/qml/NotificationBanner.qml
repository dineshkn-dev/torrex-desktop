import QtQuick
import QtQuick.Controls.Basic
import Torrin

Rectangle {
    id: root
    visible: opacity > 0 && appController.notificationMessage.length > 0
    opacity: 0
    radius: Theme.radiusMedium
    color: Theme.surfaceElevated
    border.color: Theme.accent
    border.width: 1
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    anchors.top: parent ? parent.top : undefined
    anchors.topMargin: Theme.spacingLg
    width: Math.min(400, parent ? parent.width - 48 : 400)
    implicitHeight: messageLabel.implicitHeight + Theme.spacingLg * 2
    z: 1000

    Label {
        id: messageLabel
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        text: appController.notificationMessage
        color: Theme.textPrimary
        font.pixelSize: Theme.fontBody
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    Connections {
        target: appController
        function onNotificationMessageChanged() {
            if (appController.notificationMessage.length > 0) {
                showTimer.restart()
                fadeIn.restart()
            } else {
                fadeOut.restart()
            }
        }
    }

    Timer {
        id: showTimer
        interval: 5000
        onTriggered: appController.clearNotification()
    }

    NumberAnimation {
        id: fadeIn
        target: root
        property: "opacity"
        to: 1
        duration: 200
    }

    NumberAnimation {
        id: fadeOut
        target: root
        property: "opacity"
        to: 0
        duration: 280
    }

    MouseArea {
        anchors.fill: parent
        onClicked: appController.clearNotification()
    }
}
