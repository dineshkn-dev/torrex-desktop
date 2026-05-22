import QtQuick
import QtQuick.Controls.Basic
import Torrex

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
}
