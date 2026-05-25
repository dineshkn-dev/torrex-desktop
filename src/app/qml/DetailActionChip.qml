import QtQuick
import QtQuick.Controls.Basic
import Torrin

// Neutral pill action with a leading symbol (no tinted backgrounds).
ToolButton {
    id: root
    implicitHeight: 34
    padding: 12
    enabled: root.enabled

    property string glyph: ""

    readonly property int _lineHeight: 16

    background: Rectangle {
        radius: 17
        color: {
            if (!root.enabled)
                return "transparent"
            if (root.pressed)
                return Theme.accentPressed
            if (root.hovered)
                return Theme.hover
            return "transparent"
        }
        border.color: Theme.border
        border.width: 1

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    readonly property color _textColor: root.enabled ? Theme.textPrimary : Theme.textMuted

    contentItem: Row {
        spacing: Theme.spacingXs
        height: root._lineHeight

        Item {
            width: glyphText.width
            height: parent.height

            Text {
                id: glyphText
                anchors.centerIn: parent
                text: root.glyph
                font.pixelSize: Theme.fontCaption
                font.weight: Font.DemiBold
                color: root._textColor
            }
        }

        Text {
            id: labelText
            text: root.text
            height: parent.height
            font.pixelSize: Theme.fontCaption
            font.weight: Font.DemiBold
            color: root._textColor
            verticalAlignment: Text.AlignVCenter
        }
    }
}
