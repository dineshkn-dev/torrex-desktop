import QtQuick
import Torrin

// Theme-colored magnifying glass for search fields.
Item {
    id: root
    implicitWidth: 18
    implicitHeight: 18

    property color color: Theme.textSecondary

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = root.color
            ctx.lineWidth = 1.7
            ctx.lineCap = "round"

            const r = Math.min(width, height) * 0.32
            const cx = width * 0.42
            const cy = height * 0.42

            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(cx + r * 0.72, cy + r * 0.72)
            ctx.lineTo(width * 0.88, height * 0.88)
            ctx.stroke()
        }
    }

    onColorChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
}
