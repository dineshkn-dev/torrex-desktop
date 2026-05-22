pragma Singleton
import QtQuick

// Design tokens; appearance from appController (accent, light/dark/AMOLED).
QtObject {
    readonly property var _app: typeof appController !== "undefined" ? appController : null
    readonly property int appearanceMode: _app ? _app.appearanceMode : 0
    readonly property string accentId: _app ? _app.accentColorId : "blue"

    readonly property int systemColorScheme: Application.styleHints.colorScheme
    readonly property bool dark: {
        if (appearanceMode === 1)
            return false
        if (appearanceMode === 2 || appearanceMode === 3)
            return true
        return systemColorScheme === Qt.ColorScheme.Dark
    }
    readonly property bool amoled: appearanceMode === 3
    readonly property bool light: !dark

    readonly property color accent: {
        const table = accentColors
        return table[accentId] !== undefined ? table[accentId] : table.blue
    }
    readonly property color accentPressed: Qt.darker(accent, 1.18)

    readonly property var accentColors: ({
        blue: "#3390ec",
        teal: "#14b8a6",
        violet: "#8b5cf6",
        rose: "#f43f5e",
        orange: "#f97316",
        green: "#22c55e"
    })

    readonly property var accentOptions: [
        { id: "blue", label: qsTr("Blue"), color: accentColors.blue },
        { id: "teal", label: qsTr("Teal"), color: accentColors.teal },
        { id: "violet", label: qsTr("Violet"), color: accentColors.violet },
        { id: "rose", label: qsTr("Rose"), color: accentColors.rose },
        { id: "orange", label: qsTr("Orange"), color: accentColors.orange },
        { id: "green", label: qsTr("Green"), color: accentColors.green }
    ]

    // Layout
    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 16
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int listWidth: 340
    readonly property int listMinWidth: 260
    readonly property int listMaxWidth: 400
    readonly property int rowHeight: 68
    readonly property int detailMaxWidth: 720
    readonly property int progressThin: 4
    readonly property int progressThick: 10

    // Motion
    readonly property int animFast: 140
    readonly property int animNormal: 220
    readonly property int animSlow: 320
    readonly property int flickDeceleration: 2400
    readonly property int maxFlickVelocity: 14000
    readonly property real wheelScrollMultiplier: 1.9
    readonly property real sheetEnterScale: 0.94
    readonly property int sheetWidth: 560
    readonly property int sheetMinHeight: 700
    readonly property int sheetMaxHeight: 860
    readonly property real sheetHeightRatio: 0.86
    readonly property int sheetMargin: 40
    readonly property color scrollBar: amoled ? "#ffffff22"
        : (dark ? "#ffffff30" : "#00000028")

    // Typography
    readonly property int fontTitle: 22
    readonly property int fontHeadline: 17
    readonly property int fontBody: 14
    readonly property int fontCaption: 12
    readonly property int fontStat: 15

    // Surfaces
    readonly property color windowBackground: amoled ? "#000000"
        : (dark ? "#0e1621" : "#ffffff")
    readonly property color sidebarBackground: amoled ? "#000000"
        : (dark ? "#17212b" : "#f7f8fa")
    readonly property color surface: amoled ? "#050505"
        : (dark ? "#1e2a38" : "#ffffff")
    readonly property color surfaceCard: amoled ? "#0c0c0c"
        : (dark ? "#243447" : "#f4f6f8")
    readonly property color surfaceElevated: amoled
        ? Qt.rgba(accent.r, accent.g, accent.b, 0.14)
        : (dark ? Qt.rgba(accent.r, accent.g, accent.b, 0.28) : "#eef6fc")
    readonly property color hover: amoled ? "#141414"
        : (dark ? "#202b36" : "#f0f0f2")
    readonly property color selected: accent
    readonly property color selectedMuted: amoled
        ? Qt.rgba(accent.r, accent.g, accent.b, 0.32)
        : (dark ? Qt.rgba(accent.r, accent.g, accent.b, 0.4) : Qt.rgba(accent.r, accent.g, accent.b, 0.13))

    readonly property color textPrimary: amoled ? "#f5f5f5"
        : (dark ? "#f5f5f5" : "#000000")
    readonly property color textSecondary: amoled ? "#8e8e93"
        : (dark ? "#708499" : "#707579")
    readonly property color textMuted: textSecondary
    readonly property color textOnAccent: "#ffffff"
    readonly property color divider: amoled ? "#1c1c1e"
        : (dark ? "#101921" : "#e6e6e6")
    readonly property color border: amoled ? "#2c2c2e"
        : (dark ? "#101921" : "#dadce0")

    readonly property color success: "#4fae4e"
    readonly property color warning: "#e5a64e"
    readonly property color error: "#e53935"

    function stateColor(torrentState) {
        switch (torrentState) {
        case 2: return accent
        case 3: return success
        case 4: return textSecondary
        case 5: return error
        case 1: return warning
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
