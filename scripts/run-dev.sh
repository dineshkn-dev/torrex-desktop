#!/usr/bin/env bash
# Launch the dev app bundle (new QML UI). Do not run build/dev/bin/torrex — that binary is stale.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${ROOT}/build/dev/bin"
APP="${BIN}/torrex.app"

if [[ ! -d "${APP}/Contents/MacOS" ]]; then
  echo "error: ${APP} not found. Build first:" >&2
  echo "  cmake --preset dev && cmake --build --preset dev" >&2
  exit 1
fi

# Old non-bundle executable embeds pre-revamp QML; remove so it cannot be launched by mistake.
if [[ -f "${BIN}/torrex" ]]; then
  rm -f "${BIN}/torrex"
  echo "removed stale ${BIN}/torrex (use torrex.app only)"
fi

exec open "${APP}"
