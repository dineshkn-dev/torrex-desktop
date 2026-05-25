import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import Torrin

// Rounded input field (Telegram-style).
TextField {
    id: root
    leftPadding: 14
    rightPadding: 14
    topPadding: 10
    bottomPadding: 10
    color: Theme.textPrimary
    selectionColor: Theme.accent
    selectedTextColor: Theme.textOnAccent
    placeholderTextColor: Theme.textSecondary
    font.pixelSize: Theme.fontBody

    background: Rectangle {
        implicitHeight: 40
        radius: Theme.radiusMedium
        color: Theme.surface
        border.color: root.activeFocus ? Theme.accent : Theme.border
        border.width: root.activeFocus ? 2 : 1
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

    // Override Basic TextField's TextEditingContextMenu; open at click, not caret.
    ContextMenu.menu: editMenu
    ContextMenu.onRequested: function(position) {
        const index = root.positionAt(position.x, position.y)
        if (index >= 0)
            root.cursorPosition = index
        editMenu.popupAt(root, position.x, position.y)
    }
}
