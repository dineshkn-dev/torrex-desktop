#!/bin/sh
# Dev launcher: runs the app bundle (current QML UI). Generated copy lives at build/dev/bin/torrin.
DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
# Core logs (session / magnet preview): TORRIN_LOG=1
# Qt logs: QT_LOGGING_RULES=torrin.preview=true
export TORRIN_LOG="${TORRIN_LOG:-1}"
export QT_LOGGING_RULES="${QT_LOGGING_RULES:-torrin.preview=true}"
exec "${DIR}/torrin.app/Contents/MacOS/torrin" "$@"
