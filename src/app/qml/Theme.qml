pragma Singleton
import QtQuick

// Colors follow System Settings → Appearance via Application.styleHints.colorScheme.
QtObject {
    readonly property int systemColorScheme: Application.styleHints.colorScheme
    readonly property bool dark: systemColorScheme === Qt.ColorScheme.Dark

    readonly property color windowBackground: dark ? "#1e1e2e" : "#f5f5f7"
    readonly property color surface: dark ? "#2a2a3c" : "#ffffff"
    readonly property color accent: "#3b82f6"
    readonly property color textPrimary: dark ? "#cdd6f4" : "#1e1e2e"
    readonly property color textMuted: dark ? "#a6adc8" : "#5c5c6e"
    readonly property color border: dark ? "#45475a" : "#d8d8de"
    readonly property color success: "#40a02b"
    readonly property color error: "#d20f39"
}
