#!/usr/bin/env bash
# Capture maximized Torrin window screenshots for README / releases (macOS only).
# Set TORRIN_SCREENSHOT=1 before launch for sanitized paths and demo torrents.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export TORRIN_SCREENSHOT="${TORRIN_SCREENSHOT:-1}"
OUT="${ROOT}/docs/assets"
APP="${ROOT}/build/dev/bin/torrin.app"
CAPTURE="${ROOT}/scripts/capture-window.swift"
DARK="${OUT}/torrin-dark.png"
LIGHT="${OUT}/torrin-light.png"

mkdir -p "${OUT}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "error: macOS only" >&2
  exit 1
fi

if [[ ! -d "${APP}/Contents/MacOS" ]]; then
  echo "error: ${APP} not found. Build first:" >&2
  echo "  cmake --preset dev && cmake --build --preset dev" >&2
  exit 1
fi

quit_torrin() {
  osascript -e 'tell application "torrin" to quit' 2>/dev/null || true
}

trap quit_torrin EXIT

quit_torrin
rm -rf "$(python3 -c 'import tempfile; print(tempfile.gettempdir())')/torrin-screenshot-session" 2>/dev/null || true
mkdir -p /Users/Shared/Torrin/Downloads
TORRIN_SCREENSHOT=1 "${APP}/Contents/MacOS/torrin" &
echo "Waiting for demo torrents and metadata…"
sleep 28

osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' 2>/dev/null || true
sleep 0.4
swift "${CAPTURE}" torrin "${DARK}"
echo "wrote ${DARK}"

osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to false' 2>/dev/null || true
sleep 0.6
swift "${CAPTURE}" torrin "${LIGHT}"
echo "wrote ${LIGHT}"

sips -Z 1280 "${DARK}" "${LIGHT}" >/dev/null
quit_torrin
echo "Done."
