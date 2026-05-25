import QtQuick
import QtQuick.Controls.Basic
import Torrin

// Popup menu picker (replaces ComboBox; no dropdown PNG assets).
Item {
    id: root
    implicitHeight: 36
    implicitWidth: pickerButton.implicitWidth

    property var model: []
    property int currentIndex: 0
    property string textRole: "label"

    signal activated(int index)

    function labelAt(index) {
        if (index < 0 || index >= model.length)
            return ""
        const row = model[index]
        if (typeof row === "object" && row !== null && textRole in row)
            return row[textRole]
        return String(row)
    }

    TgButton {
        id: pickerButton
        anchors.fill: parent
        text: root.labelAt(root.currentIndex)
        onClicked: pickerMenu.popupAt(pickerButton, 0, pickerButton.height)
    }

    TgMenu {
        id: pickerMenu
        Repeater {
            model: root.model
            delegate: MenuItem {
                required property int index
                text: root.labelAt(index)
                onTriggered: {
                    root.currentIndex = index
                    root.activated(index)
                }
            }
        }
    }
}
