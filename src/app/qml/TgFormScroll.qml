import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

// Scrollable form body for sheets and detail panes (width tracks viewport).
TgScrollView {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    readonly property real formWidth: availableWidth > 0 ? availableWidth : width

    default property alias content: formColumn.data

    ColumnLayout {
        id: formColumn
        width: root.formWidth
        spacing: Theme.spacingLg
    }
}
