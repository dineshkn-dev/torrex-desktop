import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import Torrin

// Pill search field with icon, focus glow, and clear action.
TextField {
    id: root
    leftPadding: 40
    rightPadding: clearButton.visible ? 38 : 16
    topPadding: 11
    bottomPadding: 11
    color: Theme.textPrimary
    selectionColor: Theme.accent
    selectedTextColor: Theme.textOnAccent
    placeholderTextColor: Theme.textMuted
    font.pixelSize: Theme.fontBody

    Keys.onEscapePressed: function(event) {
        focus = false
        event.accepted = true
    }

    background: Item {
        implicitHeight: 44

        Rectangle {
            id: fieldBg
            anchors.fill: parent
            radius: height / 2
            color: Theme.dark ? Theme.amoledElevated : Theme.surface
            border.width: root.activeFocus ? 1 : 0
            border.color: Theme.accentGlow(root.activeFocus ? 0.4 : 0)

            Behavior on border.width {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            anchors.fill: fieldBg
            radius: fieldBg.radius
            opacity: root.activeFocus ? 1 : (root.text.length > 0 ? 0.65 : 0.35)
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0
                    color: Theme.accentGlow(root.activeFocus ? 0.14 : 0.05)
                }
                GradientStop { position: 1; color: "transparent" }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    TgSearchIcon {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        color: root.activeFocus ? Theme.accent : Theme.textSecondary

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    ToolButton {
        id: clearButton
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
        visible: root.text.length > 0
        opacity: visible ? 1 : 0
        padding: 0
        onClicked: root.text = ""

        background: Rectangle {
            radius: 14
            color: clearButton.pressed ? Theme.accentPressed
                : (clearButton.hovered ? Theme.hover : Theme.accentGlow(0.12))
        }

        contentItem: Text {
            text: "×"
            font.pixelSize: 18
            font.weight: Font.Medium
            color: Theme.textSecondary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    TgMenu {
        id: editMenu

        MenuItem {
            text: qsTr("Undo")
            enabled: root.canUndo
            onTriggered: root.undo()
        }
        MenuItem {
            text: qsTr("Redo")
            enabled: root.canRedo
            onTriggered: root.redo()
        }
        TgMenuSeparator {}
        MenuItem {
            text: qsTr("Cut")
            enabled: root.selectedText.length > 0 && !root.readOnly
            onTriggered: root.cut()
        }
        MenuItem {
            text: qsTr("Copy")
            enabled: root.selectedText.length > 0
            onTriggered: root.copy()
        }
        MenuItem {
            text: qsTr("Paste")
            enabled: root.canPaste && !root.readOnly
            onTriggered: root.paste()
        }
        MenuItem {
            text: qsTr("Delete")
            enabled: root.selectedText.length > 0 && !root.readOnly
            onTriggered: root.remove(root.selectionStart, root.selectionEnd)
        }
        TgMenuSeparator {}
        MenuItem {
            text: qsTr("Select All")
            enabled: root.text.length > 0
            onTriggered: root.selectAll()
        }
    }

    ContextMenu.menu: editMenu
    ContextMenu.onRequested: function(position) {
        const index = root.positionAt(position.x, position.y)
        if (index >= 0)
            root.cursorPosition = index
        editMenu.popupAt(root, position.x, position.y)
    }
}
