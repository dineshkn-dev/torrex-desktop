#!/usr/bin/env bash
# Launch the dev app bundle. Prefer ./build/dev/bin/torrin (launcher) or open torrin.app directly.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${ROOT}/build/dev/bin"
APP="${BIN}/torrin.app"

if [[ ! -d "${APP}/Contents/MacOS" ]]; then
  echo "error: ${APP} not found. Build first:" >&2
  echo "  cmake --preset dev && cmake --build --preset dev" >&2
  exit 1
fi

# Old non-bundle executable embeds pre-revamp QML; remove so it cannot be launched by mistake.
# Remove legacy flat Mach-O executables (pre-bundle layout).
if [[ -f "${BIN}/torrex" ]] && file "${BIN}/torrex" | grep -q Mach-O; then
  rm -f "${BIN}/torrex"
  echo "removed stale ${BIN}/torrex"
fi
if [[ -f "${BIN}/torrin" ]] && file "${BIN}/torrin" | grep -q Mach-O; then
  rm -f "${BIN}/torrin"
  echo "removed stale ${BIN}/torrin (use torrin.app or the shell launcher)"
fi

exec open "${APP}"
