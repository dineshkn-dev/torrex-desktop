#!/usr/bin/env bash
# Generate macOS Torrin.icns from resources/brand/torrin-app-icon.svg
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SVG="${ROOT}/resources/brand/torrin-app-icon.svg"
ICONSET="${ROOT}/resources/macos/Torrin.iconset"
ICNS="${ROOT}/resources/macos/Torrin.icns"

if [[ ! -f "$SVG" ]]; then
    echo "Missing ${SVG}" >&2
    exit 1
fi

if ! command -v rsvg-convert >/dev/null 2>&1; then
    echo "rsvg-convert not found (brew install librsvg)" >&2
    exit 1
fi

rm -rf "$ICONSET"
mkdir -p "$ICONSET"

render() {
    local px="$1"
    local out="$2"
    rsvg-convert -w "$px" -h "$px" "$SVG" -o "${ICONSET}/${out}"
}

render 16 icon_16x16.png
render 32 icon_16x16@2x.png
render 32 icon_32x32.png
render 64 icon_32x32@2x.png
render 128 icon_128x128.png
render 256 icon_128x128@2x.png
render 256 icon_256x256.png
render 512 icon_256x256@2x.png
render 512 icon_512x512.png
render 1024 icon_512x512@2x.png

iconutil -c icns "$ICONSET" -o "$ICNS"
echo "Wrote ${ICNS}"
