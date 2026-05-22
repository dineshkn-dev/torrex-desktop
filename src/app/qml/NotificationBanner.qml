import QtQuick
import QtQuick.Controls.Basic
import Torrex

// Transient in-app notification (download complete, etc.).
Rectangle {
    id: root
    visible: opacity > 0 && appController.notificationMessage.length > 0
    opacity: 0
    radius: 8
    color: Theme.accent
    border.color: Theme.border
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    anchors.top: parent ? parent.top : undefined
    anchors.topMargin: 12
    width: Math.min(420, parent ? parent.width - 32 : 420)
    implicitHeight: messageLabel.implicitHeight + 24
    z: 1000

    Label {
        id: messageLabel
        anchors.fill: parent
        anchors.margins: 12
        text: appController.notificationMessage
        color: Theme.windowBackground
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
        interval: 6000
        onTriggered: appController.clearNotification()
    }

    NumberAnimation {
        id: fadeIn
        target: root
        property: "opacity"
        to: 0.95
        duration: 200
    }

    NumberAnimation {
        id: fadeOut
        target: root
        property: "opacity"
        to: 0
        duration: 300
    }

    MouseArea {
        anchors.fill: parent
        onClicked: appController.clearNotification()
    }
}
