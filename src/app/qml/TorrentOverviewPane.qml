import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Torrex

// Overview tab: transfer stats + save path (fills detail pane).
Item {
    id: root

    required property string downloadRateText
    required property string uploadRateText
    required property string savePath

    ScrollView {
        id: scroll
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            id: content
            width: scroll.availableWidth > 0 ? scroll.availableWidth : scroll.width
            spacing: Theme.spacingLg

            DetailCard {
                title: qsTr("Transfer")

                DetailStatRow {
                    label: qsTr("Download")
                    value: root.downloadRateText
                }
                DetailStatRow {
                    label: qsTr("Upload")
                    value: root.uploadRateText
                }
            }

            DetailCard {
                title: qsTr("Storage")

                DetailStatRow {
                    label: qsTr("Save folder")
                    value: root.savePath.length > 0 ? root.savePath : qsTr("—")
                    wrapValue: true
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
