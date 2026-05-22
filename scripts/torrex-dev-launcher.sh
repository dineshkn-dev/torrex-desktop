#!/bin/sh
# Dev launcher: runs the app bundle (current QML UI). Generated copy lives at build/dev/bin/torrex.
DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
# Core logs (session / magnet preview): TORREX_LOG=1
# Qt logs: QT_LOGGING_RULES=torrex.preview=true
export TORREX_LOG="${TORREX_LOG:-1}"
export QT_LOGGING_RULES="${QT_LOGGING_RULES:-torrex.preview=true}"
exec "${DIR}/torrex.app/Contents/MacOS/torrex" "$@"
