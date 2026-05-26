#!/usr/bin/env python3
"""Render README preview PNGs from Theme.qml palette (fallback when screencapture unavailable)."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("error: install Pillow (pip install Pillow)", file=sys.stderr)
    sys.exit(1)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "assets"
ICON_SVG = ROOT / "resources" / "brand" / "torrin-app-icon.svg"

W, H = 1024, 680
SIDEBAR = 200
LIST_W = 340
ACCENT = (0x33, 0x90, 0xEC)

DARK = {
    "window": (0, 0, 0),
    "sidebar": (0, 0, 0),
    "card": (12, 12, 12),
    "elevated": (17, 17, 17),
    "divider": (28, 28, 30),
    "border": (44, 44, 46),
    "text": (245, 245, 245),
    "muted": (142, 142, 147),
    "selected": (28, 28, 30),
}

LIGHT = {
    "window": (255, 255, 255),
    "sidebar": (247, 248, 250),
    "card": (244, 246, 248),
    "elevated": (238, 246, 252),
    "divider": (230, 230, 230),
    "border": (218, 220, 224),
    "text": (0, 0, 0),
    "muted": (112, 117, 121),
    "selected": (51, 144, 236, 33),  # accent tint
}


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    paths = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial.ttf",
    ]
    for p in paths:
        if Path(p).exists():
            try:
                return ImageFont.truetype(p, size)
            except OSError:
                continue
    return ImageFont.load_default()


def rounded_rect(draw, xy, fill, radius=12):
    draw.rounded_rectangle(xy, radius=radius, fill=fill)


def render(palette: dict, path: Path) -> None:
    img = Image.new("RGB", (W, H), palette["window"])
    draw = ImageDraw.Draw(img)
    font_title = load_font(22, True)
    font_body = load_font(14)
    font_cap = load_font(12)

    # Sidebar
    draw.rectangle((0, 0, SIDEBAR, H), fill=palette["sidebar"])
    draw.text((24, 28), "Torrin", fill=palette["text"], font=font_title)
    filters = ["All", "Downloading", "Seeding", "Paused"]
    y = 88
    for i, label in enumerate(filters):
        if i == 0:
            rounded_rect(draw, (16, y, SIDEBAR - 16, y + 36), ACCENT, 10)
            draw.text((28, y + 9), label, fill=(255, 255, 255), font=font_body)
        else:
            draw.text((28, y + 9), label, fill=palette["muted"], font=font_body)
        y += 44

    lx = SIDEBAR
    # List pane background
    draw.rectangle((lx, 0, lx + LIST_W, H), fill=palette["window"])
    rounded_rect(draw, (lx + 12, 16, lx + LIST_W - 12, 88), palette["card"], 12)
    draw.text((lx + 28, 34), "Search torrents…", fill=palette["muted"], font=font_body)
    # Sort chips
    rounded_rect(draw, (lx + 28, 56, lx + 120, 78), palette["elevated"], 8)
    draw.rectangle((lx + 28, 56, lx + 120, 78), outline=ACCENT, width=2)
    draw.text((lx + 40, 60), "Name", fill=ACCENT, font=font_cap)

    torrents = [
        ("Ubuntu 24.04 LTS", "Downloading", "4.2 MB/s", "12m 4s", True),
        ("Fedora Workstation", "Seeding", "1.1 MB/s", "Done", False),
        ("Debian netinst", "Paused", "—", "Paused", False),
    ]
    row_y = 104
    for name, state, down, eta, selected in torrents:
        ry0, ry1 = row_y, row_y + 68
        if selected:
            if isinstance(palette["selected"], tuple) and len(palette["selected"]) == 4:
                overlay = Image.new("RGBA", (LIST_W, 68), palette["selected"])
                img.paste(overlay, (lx, ry0), overlay)
            else:
                draw.rectangle((lx, ry0, lx + LIST_W, ry1), fill=palette["selected"])
        draw.line((lx + 16, ry1, lx + LIST_W - 16, ry1), fill=palette["divider"], width=1)
        state_color = ACCENT if state == "Downloading" else (79, 174, 78) if state == "Seeding" else palette["muted"]
        draw.text((lx + 20, ry0 + 12), name, fill=palette["text"], font=font_body)
        draw.text((lx + 20, ry0 + 34), state, fill=state_color, font=font_cap)
        draw.text((lx + LIST_W - 100, ry0 + 34), down, fill=palette["muted"], font=font_cap)
        draw.text((lx + LIST_W - 52, ry0 + 12), eta, fill=palette["muted"], font=font_cap)
        row_y += 68

    # Detail pane
    dx = lx + LIST_W
    draw.line((dx, 0, dx, H), fill=palette["divider"], width=1)
    draw.text((dx + 24, 28), torrents[0][0], fill=palette["text"], font=font_title)
    rounded_rect(draw, (dx + 24, 72, dx + 200, 104), palette["card"], 10)
    draw.text((dx + 40, 86), "Overview", fill=ACCENT, font=font_body)
    draw.text((dx + 130, 86), "Files", fill=palette["muted"], font=font_body)

    rounded_rect(draw, (dx + 24, 128, W - 24, 280), palette["card"], 14)
    draw.text((dx + 44, 148), "Progress", fill=palette["muted"], font=font_cap)
    draw.rectangle((dx + 44, 178, W - 44, 182), fill=palette["divider"])
    draw.rectangle((dx + 44, 178, dx + 44 + int((W - dx - 88) * 0.62), 182), fill=ACCENT)
    draw.text((dx + 44, 200), "62%", fill=palette["text"], font=font_body)
    draw.text((dx + 44, 232), "↓ 4.2 MB/s", fill=palette["text"], font=font_body)
    draw.text((dx + 200, 232), "↑ 128 KB/s", fill=palette["muted"], font=font_body)

    # App icon watermark
    icon_png = OUT / "_icon_tmp.png"
    if ICON_SVG.exists():
        subprocess.run(
            ["rsvg-convert", "-w", "48", "-h", "48", str(ICON_SVG), "-o", str(icon_png)],
            check=False,
            capture_output=True,
        )
        if icon_png.exists():
            icon = Image.open(icon_png).convert("RGBA")
            img.paste(icon, (W - 72, 20), icon)
            icon_png.unlink(missing_ok=True)

    OUT.mkdir(parents=True, exist_ok=True)
    img.save(path, "PNG", optimize=True)
    print(f"wrote {path}")


def main() -> None:
    render(DARK, OUT / "torrin-dark.png")
    render(LIGHT, OUT / "torrin-light.png")


if __name__ == "__main__":
    main()
