#!/usr/bin/env bash
# Package torrin into a portable .tar.gz using linuxdeploy + Qt plugin (Linux CI).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/qt-deploy-common.sh
source "$ROOT/scripts/qt-deploy-common.sh"

BUILD_DIR="${1:-$ROOT/build/ci-release}"
BIN="$BUILD_DIR/bin/torrin"
STAGING="$BUILD_DIR/staging"
VERSION="$(torrin_version "$ROOT")"
QML_DIR="$ROOT/src/app/qml"
APPDIR="$BUILD_DIR/appdir"
CACHE="$BUILD_DIR/linuxdeploy-cache"

if [[ ! -x "$BIN" ]]; then
    echo "package-linux: missing $BIN (build with ci-release on Linux)" >&2
    exit 1
fi

mkdir -p "$CACHE"
LINUXDEPLOY="$CACHE/linuxdeploy-x86_64.AppImage"
PLUGIN="$CACHE/linuxdeploy-plugin-qt-x86_64.AppImage"

if [[ ! -x "$LINUXDEPLOY" ]]; then
    wget -q -O "$LINUXDEPLOY" \
        "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
    chmod +x "$LINUXDEPLOY"
fi
if [[ ! -x "$PLUGIN" ]]; then
    wget -q -O "$PLUGIN" \
        "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
    chmod +x "$PLUGIN"
fi

ICON_PNG="$CACHE/torrin-256.png"
if [[ ! -f "$ICON_PNG" ]]; then
    if command -v rsvg-convert >/dev/null 2>&1; then
        rsvg-convert -w 256 -h 256 "$ROOT/resources/brand/torrin-app-icon.svg" -o "$ICON_PNG"
    else
        ICON_PNG=""
    fi
fi

rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
cp "$BIN" "$APPDIR/usr/bin/torrin"
chmod +x "$APPDIR/usr/bin/torrin"

export QML_SOURCES_PATHS="$QML_DIR"
export EXTRA_PLATFORM_PLUGINS="libqxcb.so"

DEPLOY_ARGS=(--appdir "$APPDIR" -e "$APPDIR/usr/bin/torrin" --plugin qt)
if [[ -n "$ICON_PNG" && -f "$ICON_PNG" ]]; then
    DEPLOY_ARGS+=(--icon-file "$ICON_PNG")
fi

echo "package-linux: linuxdeploy ${DEPLOY_ARGS[*]}"
"$LINUXDEPLOY" --appimage-extract-and-run "${DEPLOY_ARGS[@]}"

ARCHIVE_NAME="Torrin-${VERSION}-linux-x64.tar.gz"
ARCHIVE_PATH="$STAGING/$ARCHIVE_NAME"
rm -rf "$STAGING"
mkdir -p "$STAGING"
tar -czf "$ARCHIVE_PATH" -C "$APPDIR" .

(
    cd "$STAGING"
    sha256sum "$ARCHIVE_NAME" >>SHA256SUMS.txt
)

echo "package-linux: wrote $ARCHIVE_PATH"
echo "$STAGING"
