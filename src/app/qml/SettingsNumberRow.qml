import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

// Numeric setting with +/- steppers (avoids SpinBox style assets).
RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: Theme.spacingMd

    property string label: ""
    property int value: 0
    property int minimum: 0
    property int maximum: 102400
    property int step: 1
    property string suffix: ""

    signal valueModified(int newValue)

    Label {
        text: root.label
        font.pixelSize: Theme.fontBody
        color: Theme.textSecondary
        Layout.preferredWidth: 108
        Layout.alignment: Qt.AlignVCenter
    }

    RowLayout {
        spacing: Theme.spacingSm
        Layout.fillWidth: true

        TgIconButton {
            text: "−"
            onClicked: root.applyValue(root.value - root.step)
        }

        TgTextField {
            id: valueField
            Layout.fillWidth: true
            Layout.maximumWidth: 120
            horizontalAlignment: Text.AlignHCenter
            text: String(root.value)
            inputMethodHints: Qt.ImhDigitsOnly
            onEditingFinished: {
                const parsed = parseInt(text, 10)
                if (!isNaN(parsed))
                    root.applyValue(parsed)
                else
                    valueField.text = String(root.value)
            }
        }

        TgIconButton {
            text: "+"
            onClicked: root.applyValue(root.value + root.step)
        }

        Label {
            visible: root.suffix.length > 0
            text: root.suffix
            font.pixelSize: Theme.fontCaption
            color: Theme.textSecondary
        }
    }

    function applyValue(candidate) {
        const clamped = Math.max(root.minimum, Math.min(root.maximum, candidate))
        valueField.text = String(clamped)
        if (clamped !== root.value)
            root.valueModified(clamped)
    }

    onValueChanged: {
        if (valueField.text !== String(root.value))
            valueField.text = String(root.value)
    }
}
