pragma Singleton
import QtQuick

// Design tokens; appearance from appController. Dark = AMOLED (true black, neutral grays).
QtObject {
    readonly property var _app: typeof appController !== "undefined" ? appController : null
    readonly property int appearanceMode: _app ? _app.appearanceMode : 0
    readonly property string accentId: _app ? _app.accentColorId : "blue"

    readonly property int systemColorScheme: Application.styleHints.colorScheme
    readonly property bool dark: {
        if (appearanceMode === 1)
            return false
        if (appearanceMode === 2)
            return true
        return systemColorScheme === Qt.ColorScheme.Dark
    }
    readonly property bool amoled: dark
    readonly property bool light: !dark

    // Dark palette: pure black + neutral grays; accent never tints surfaces.
    readonly property color amoledWindow: "#000000"
    readonly property color amoledSurface: "#050505"
    readonly property color amoledSurfaceCard: "#0c0c0c"
    readonly property color amoledElevated: "#111111"
    readonly property color amoledHover: "#141414"
    readonly property color amoledSelected: "#1c1c1e"
    readonly property color amoledDivider: "#1c1c1e"
    readonly property color amoledBorder: "#2c2c2e"
    readonly property color amoledTextPrimary: "#f5f5f5"
    readonly property color amoledTextSecondary: "#8e8e93"

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
    readonly property int spacingXl: 24
    readonly property int sheetPadding: 24
    readonly property int listWidth: 340
    readonly property int listMinWidth: 260
    readonly property int listMaxWidth: 520
    readonly property int rowHeight: 68
    readonly property int detailMinWidth: 360
    readonly property int detailMaxWidth: 720
    readonly property int progressThin: 4
    readonly property int progressThick: 10

    // Motion
    readonly property int animFast: 140
    readonly property int animNormal: 220
    readonly property int animSlow: 320
    readonly property int flickDeceleration: 2000
    readonly property int maxFlickVelocity: 15000
    // Mouse wheels use angleDelta (120 per notch); trackpads use pixelDelta.
    readonly property int mouseWheelLinePixels: 72
    readonly property real mouseWheelScrollMultiplier: 1.0
    readonly property real trackpadScrollMultiplier: 1.0
    readonly property real sheetEnterScale: 0.94
    readonly property int sheetWidth: 640
    readonly property int sheetWideWidth: 760
    readonly property int sheetMinHeight: 700
    readonly property int sheetMaxHeight: 880
    readonly property real sheetHeightRatio: 0.86
    readonly property int sheetMargin: 40
    readonly property color scrollBar: dark ? "#ffffff22" : "#00000028"

    // Typography
    readonly property int fontTitle: 22
    readonly property int fontHeadline: 17
    readonly property int fontBody: 14
    readonly property int fontCaption: 12
    readonly property int fontStat: 15

    // Surfaces
    readonly property color windowBackground: dark ? amoledWindow : "#ffffff"
    readonly property color sidebarBackground: dark ? amoledWindow : "#f7f8fa"
    readonly property color surface: dark ? amoledSurface : "#ffffff"
    readonly property color surfaceCard: dark ? amoledSurfaceCard : "#f4f6f8"
    readonly property color surfaceElevated: dark ? amoledElevated : "#eef6fc"
    readonly property color hover: dark ? amoledHover : "#f0f0f2"
    readonly property color selected: accent
    readonly property color selectedMuted: dark ? amoledSelected
        : Qt.rgba(accent.r, accent.g, accent.b, 0.13)

    readonly property color textPrimary: dark ? amoledTextPrimary : "#000000"
    readonly property color textSecondary: dark ? amoledTextSecondary : "#707579"
    readonly property color textMuted: textSecondary
    readonly property color textOnAccent: "#ffffff"
    readonly property color divider: dark ? amoledDivider : "#e6e6e6"
    readonly property color border: dark ? amoledBorder : "#dadce0"

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

    function stateLabel(torrentState, uploadStopped) {
        if (torrentState === 3 && uploadStopped)
            return qsTr("Seeding (upload stopped)")
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

    function canStopSeeding(torrentState, progress, uploadStopped) {
        return torrentState === 3 && progress >= 100 && !uploadStopped
    }

    function canResumeSeeding(torrentState, progress, uploadStopped) {
        return torrentState === 3 && progress >= 100 && uploadStopped
    }

    function formatBytes(bytes) {
        const n = Number(bytes)
        if (!isFinite(n) || n <= 0)
            return qsTr("0 B")
        bytes = n
        if (bytes < 1024)
            return bytes + " B"
        if (bytes < 1024 * 1024)
            return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1024 * 1024 * 1024)
            return (bytes / (1024 * 1024)).toFixed(1) + " MB"
        return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB"
    }

    function formatRate(bytesPerSec) {
        if (bytesPerSec <= 0)
            return qsTr("—")
        return formatBytes(bytesPerSec) + "/s"
    }

    function formatRateForTorrent(bytesPerSec, paused) {
        if (paused)
            return qsTr("—")
        return formatRate(bytesPerSec)
    }

    function formatEta(seconds) {
        if (seconds < 0)
            return qsTr("—")
        if (seconds < 60)
            return qsTr("%1s").arg(seconds)
        if (seconds < 3600) {
            const m = Math.floor(seconds / 60)
            const s = seconds % 60
            return qsTr("%1m %2s").arg(m).arg(s)
        }
        const h = Math.floor(seconds / 3600)
        const m = Math.floor((seconds % 3600) / 60)
        return qsTr("%1h %2m").arg(h).arg(m)
    }

    function formatEtaForTorrent(seconds, torrentState, progress, paused) {
        if (paused || torrentState === 4)
            return qsTr("Paused")
        if (progress >= 100 || torrentState === 3)
            return qsTr("Done")
        if (torrentState === 0 || torrentState === 5)
            return qsTr("—")
        return formatEta(seconds)
    }

    function formatRatio(uploaded, downloaded) {
        if (downloaded <= 0)
            return qsTr("—")
        return (uploaded / downloaded).toFixed(2)
    }

    function shortInfoHash(hex) {
        if (!hex || hex.length < 12)
            return hex || ""
        return hex.slice(0, 8) + "…" + hex.slice(-6)
    }

    function accentGlow(alpha) {
        return Qt.rgba(accent.r, accent.g, accent.b, alpha)
    }

    function heroRingSize(paneWidth) {
        if (paneWidth <= 0)
            return 96
        if (paneWidth < 360)
            return 72
        if (paneWidth < 480)
            return 88
        return 104
    }

    function metricsGridColumns(paneWidth) {
        if (paneWidth > 0 && paneWidth < 420)
            return 1
        return 2
    }

    function stackSpeedCards(paneWidth) {
        return paneWidth > 0 && paneWidth < 400
    }

    function listPaneCompactHeader(paneWidth) {
        return paneWidth > 0 && paneWidth < 300
    }

    function listPaneChipPadding(paneWidth) {
        if (paneWidth > 0 && paneWidth < 340)
            return 8
        if (paneWidth > 0 && paneWidth < 420)
            return 10
        return 12
    }

    function showTorrentRowSpeed(paneWidth) {
        return paneWidth >= 220
    }

    function priorityColumnWidth(paneWidth) {
        if (paneWidth <= 0)
            return 76
        return Math.min(88, Math.max(64, Math.floor(paneWidth * 0.24)))
    }

    function applyFlickablePhysics(flickable) {
        if (!flickable || flickable.flickDeceleration === undefined)
            return
        flickable.flickDeceleration = flickDeceleration
        flickable.maximumFlickVelocity = maxFlickVelocity
        flickable.pixelAligned = false
        flickable.boundsBehavior = Flickable.DragAndOvershootBounds
        flickable.interactive = true
        // Wheel deltas are tuned in ScrollWheelHandler (applyWheelScroll).
    }

    function applyWheelScroll(flickable, event) {
        if (!flickable || !event)
            return

        let deltaY = 0
        let deltaX = 0
        const pixel = event.pixelDelta
        const angle = event.angleDelta

        if (pixel) {
            if (pixel.y !== 0)
                deltaY = pixel.y * trackpadScrollMultiplier
            if (pixel.x !== 0)
                deltaX = pixel.x * trackpadScrollMultiplier
        }
        if (angle) {
            if (deltaY === 0 && angle.y !== 0)
                deltaY = (angle.y / 120) * mouseWheelLinePixels * mouseWheelScrollMultiplier
            if (deltaX === 0 && angle.x !== 0)
                deltaX = (angle.x / 120) * mouseWheelLinePixels * mouseWheelScrollMultiplier
        }

        if (deltaY === 0 && deltaX === 0)
            return

        if (deltaY !== 0) {
            const minY = -flickable.topMargin
            const maxY = Math.max(minY,
                flickable.contentHeight - flickable.height + flickable.bottomMargin)
            flickable.contentY = Math.min(maxY, Math.max(minY, flickable.contentY - deltaY))
        }

        if (deltaX !== 0) {
            const minX = -flickable.leftMargin
            const maxX = Math.max(minX,
                flickable.contentWidth - flickable.width + flickable.rightMargin)
            flickable.contentX = Math.min(maxX, Math.max(minX, flickable.contentX - deltaX))
        }

        event.accepted = true
    }
}
