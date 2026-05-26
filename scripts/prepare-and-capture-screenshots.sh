#!/usr/bin/env bash
# Clean rebuild, seed demo torrents (screenshot mode), capture maximized PNGs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export TORRIN_SCREENSHOT=1

echo "==> Removing prior screenshot session"
rm -rf "${TMPDIR:-/tmp}/torrin-screenshot-session"
echo "==> Removing prior build (clean)"
rm -rf "${ROOT}/build"
rm -rf "$(python3 -c 'import tempfile; print(tempfile.gettempdir())')/torrin-screenshot-session"

echo "==> Preparing download folder for screenshots"
mkdir -p /Users/Shared/Torrin/Downloads

echo "==> Configure and build (dev preset)"
./scripts/bootstrap.sh
cmake --preset dev
cmake --build --preset dev

echo "==> Launch Torrin (demo magnets load automatically)"
osascript -e 'tell application "torrin" to quit' 2>/dev/null || true
sleep 1
open -g "${ROOT}/build/dev/bin/torrin.app"

echo "==> Waiting for metadata (demo ISO magnets)…"
sleep 25

echo "==> Capture maximized dark/light screenshots"
"${ROOT}/scripts/capture-screenshots.sh"

echo "==> Done. Review docs/assets/torrin-dark.png and torrin-light.png"
