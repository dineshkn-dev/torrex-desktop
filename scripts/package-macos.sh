#!/usr/bin/env bash
# Package Torrex.app into a compressed .dmg and write SHA-256 checksums.
# Usage: ./scripts/package-macos.sh [build/ci-release]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${1:-$ROOT/build/ci-release}"
APP="$BUILD_DIR/bin/Torrex.app"
STAGING="$BUILD_DIR/staging"
VERSION="$(grep -E 'constexpr const char\* kVersion' "$ROOT/include/torrex/version.hpp" | sed -E 's/.*"([^"]+)".*/\1/')"

if [[ ! -d "$APP" ]]; then
    echo "package-macos: missing $APP (build with ci-release preset on macOS)" >&2
    exit 1
fi

MACDEPLOYQT="${MACDEPLOYQT:-}"
if [[ -z "$MACDEPLOYQT" ]]; then
    for candidate in \
        "$BUILD_DIR/vcpkg_installed/arm64-osx/tools/Qt6/bin/macdeployqt" \
        "$BUILD_DIR/vcpkg_installed/arm64-osx/tools/qt6/bin/macdeployqt"; do
        if [[ -x "$candidate" ]]; then
            MACDEPLOYQT="$candidate"
            break
        fi
    done
fi
if [[ -z "$MACDEPLOYQT" ]]; then
    MACDEPLOYQT="$(command -v macdeployqt || true)"
fi
if [[ -n "$MACDEPLOYQT" ]]; then
    echo "package-macos: macdeployqt $APP"
    "$MACDEPLOYQT" "$APP" -always-overwrite -qmldir="$ROOT/src/app/qml"
else
    echo "package-macos: warning — macdeployqt not found; bundle may be incomplete" >&2
fi

ARCH="$(uname -m)"
DMG_NAME="Torrex-${VERSION}-macos-${ARCH}.dmg"
rm -rf "$STAGING"
mkdir -p "$STAGING"

DMG_PATH="$STAGING/$DMG_NAME"
echo "package-macos: creating $DMG_PATH"
hdiutil create -volname "Torrex" -srcfolder "$APP" -ov -format UDZO "$DMG_PATH" >/dev/null

CHECKSUMS="$STAGING/SHA256SUMS.txt"
(
    cd "$STAGING"
    shasum -a 256 "$DMG_NAME" >SHA256SUMS.txt
)
echo "package-macos: wrote $CHECKSUMS"
echo "$STAGING"
