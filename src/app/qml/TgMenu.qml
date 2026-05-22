import QtQuick
import QtQuick.Controls.Basic
import Torrex

// Themed popup menu (replaces default/native Menu chrome).
Menu {
    id: root
    popupType: Popup.Item
    padding: Theme.spacingXs

    background: Rectangle {
        implicitWidth: 200
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusMedium
    }

    delegate: MenuItem {
        id: control
        implicitHeight: 36
        leftPadding: Theme.spacingMd
        rightPadding: Theme.spacingMd

        contentItem: Text {
            text: control.text
            font.pixelSize: Theme.fontBody
            color: control.enabled ? Theme.textPrimary : Theme.textMuted
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            radius: Theme.radiusSmall
            color: control.highlighted && control.enabled ? Theme.hover : "transparent"
        }
    }

    function popupAt(item, x, y) {
        root.popup(item, x, y)
    }
}
