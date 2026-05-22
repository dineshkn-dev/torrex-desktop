pragma Singleton
import QtQuick

// Telegram-inspired design tokens; follows system light/dark when not forced.
QtObject {
    readonly property int systemColorScheme: Application.styleHints.colorScheme
    readonly property bool dark: systemColorScheme === Qt.ColorScheme.Dark

    // Layout
    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 16
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int listWidth: 340
    readonly property int rowHeight: 64
    readonly property int detailMaxWidth: 720
    readonly property int progressThin: 4
    readonly property int progressThick: 10

    // Typography
    readonly property int fontTitle: 22
    readonly property int fontHeadline: 17
    readonly property int fontBody: 14
    readonly property int fontCaption: 12
    readonly property int fontStat: 15

    // Surfaces (Telegram-like)
    readonly property color windowBackground: dark ? "#0e1621" : "#ffffff"
    readonly property color sidebarBackground: dark ? "#17212b" : "#f7f8fa"
    readonly property color surface: dark ? "#1e2a38" : "#ffffff"
    readonly property color surfaceCard: dark ? "#243447" : "#f4f6f8"
    readonly property color surfaceElevated: dark ? "#2b5278" : "#eef6fc"
    readonly property color hover: dark ? "#202b36" : "#f0f0f2"
    readonly property color selected: dark ? "#2b5278" : "#3390ec"
    readonly property color selectedMuted: dark ? "#2b527866" : "#3390ec22"

    readonly property color accent: "#3390ec"
    readonly property color accentPressed: dark ? "#2a7bc4" : "#2f7fd1"
    readonly property color textPrimary: dark ? "#f5f5f5" : "#000000"
    readonly property color textSecondary: dark ? "#708499" : "#707579"
    readonly property color textMuted: textSecondary
    readonly property color textOnAccent: "#ffffff"
    readonly property color divider: dark ? "#101921" : "#e6e6e6"
    readonly property color border: dark ? "#101921" : "#dadce0"

    readonly property color success: "#4fae4e"
    readonly property color warning: "#e5a64e"
    readonly property color error: "#e53935"

    function stateColor(torrentState) {
        switch (torrentState) {
        case 2: return accent      // Downloading
        case 3: return success     // Seeding
        case 4: return textSecondary // Paused
        case 5: return error       // Error
        case 1: return warning     // Checking
        default: return textSecondary
        }
    }

    function stateLabel(torrentState) {
        switch (torrentState) {
        case 0: return qsTr("Idle")
        case 1: return qsTr("Checking")
        case 2: return qsTr("Downloading")
        case 3: return qsTr("Seeding")
        case 4: return qsTr("Paused")
        case 5: return qsTr("Error")
        default: return qsTr("Unknown")
        }
    }
}
