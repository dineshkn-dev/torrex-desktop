import QtQuick
import Torrin

// Theme-colored gear (avoids emoji "⚙" rendering as "8" without an emoji font).
Item {
    id: root
    implicitWidth: 20
    implicitHeight: 20

    property color color: Theme.textPrimary

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = root.color
            ctx.lineWidth = 1.6
            ctx.lineJoin = "round"
            ctx.lineCap = "round"

            const cx = width / 2
            const cy = height / 2
            const outer = Math.min(width, height) * 0.42
            const inner = outer * 0.62

            ctx.beginPath()
            for (let i = 0; i < 12; ++i) {
                const angle = (i / 12) * Math.PI * 2 - Math.PI / 2
                const radius = (i % 2 === 0) ? outer : inner
                const x = cx + radius * Math.cos(angle)
                const y = cy + radius * Math.sin(angle)
                if (i === 0)
                    ctx.moveTo(x, y)
                else
                    ctx.lineTo(x, y)
            }
            ctx.closePath()
            ctx.stroke()

            ctx.beginPath()
            ctx.arc(cx, cy, inner * 0.45, 0, Math.PI * 2)
            ctx.stroke()
        }
    }

    onColorChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
}
