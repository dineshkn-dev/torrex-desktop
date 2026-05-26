import QtQuick
import QtQuick.Controls.Basic
import Torrin

// Circular progress indicator for the detail hero.
Item {
    id: root
    implicitWidth: size
    implicitHeight: size

    property int size: 96
    property real progress: 0
    property color ringColor: Theme.accent
    property color trackColor: Theme.border

    readonly property real ratio: Math.max(0, Math.min(1, progress / 100))

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            const line = Math.max(6, root.size * 0.08)
            const r = (Math.min(width, height) - line) / 2
            const cx = width / 2
            const cy = height / 2
            ctx.lineWidth = line
            ctx.lineCap = "round"
            ctx.strokeStyle = root.trackColor
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.stroke()
            if (root.ratio > 0) {
                ctx.strokeStyle = root.ringColor
                ctx.beginPath()
                ctx.arc(cx, cy, r, -Math.PI / 2,
                        -Math.PI / 2 + root.ratio * Math.PI * 2)
                ctx.stroke()
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 0
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.progress) + "%"
            font.pixelSize: root.size < 80 ? Theme.fontBody : Theme.fontHeadline
            font.weight: Font.DemiBold
            color: Theme.textPrimary
        }
    }

    onProgressChanged: canvas.requestPaint()
    onRingColorChanged: canvas.requestPaint()
    onSizeChanged: canvas.requestPaint()
    Component.onCompleted: canvas.requestPaint()
}
