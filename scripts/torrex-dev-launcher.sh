#!/bin/sh
# Dev launcher: runs the app bundle (current QML UI). Generated copy lives at build/dev/bin/torrex.
DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
exec "${DIR}/torrex.app/Contents/MacOS/torrex" "$@"
