#!/usr/bin/env bash
# Package torrin.exe with windeployqt into a portable .zip (Windows CI / cross-build).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/qt-deploy-common.sh
source "$ROOT/scripts/qt-deploy-common.sh"

BUILD_DIR="${1:-$ROOT/build/ci-release}"
EXE="$BUILD_DIR/bin/torrin.exe"
STAGING="$BUILD_DIR/staging"
VERSION="$(torrin_version "$ROOT")"
QML_DIR="$ROOT/src/app/qml"

if [[ ! -f "$EXE" ]]; then
    echo "package-windows: missing $EXE (build with ci-release on Windows)" >&2
    exit 1
fi

WINDEPLOYQT="$(find_qt_deploy_tool "$BUILD_DIR" windeployqt)" || {
    echo "package-windows: windeployqt not found" >&2
    exit 1
}

echo "package-windows: $WINDEPLOYQT $EXE"
"$WINDEPLOYQT" "$EXE" --qmldir="$QML_DIR" --no-compiler-runtime

PKG_ROOT="$STAGING/Torrin-${VERSION}-windows-x64"
rm -rf "$PKG_ROOT" "$STAGING/SHA256SUMS.txt"
mkdir -p "$PKG_ROOT" "$STAGING"
cp -r "$BUILD_DIR/bin/"* "$PKG_ROOT/"

ZIP_NAME="Torrin-${VERSION}-windows-x64.zip"
ZIP_PATH="$STAGING/$ZIP_NAME"
rm -f "$ZIP_PATH"
(
    cd "$STAGING"
    if command -v zip >/dev/null 2>&1; then
        zip -r "$ZIP_NAME" "$(basename "$PKG_ROOT")"
    else
        powershell -NoProfile -Command "Compress-Archive -Path '$(basename "$PKG_ROOT")' -DestinationPath '$ZIP_NAME' -Force"
    fi
)

(
    cd "$STAGING"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$ZIP_NAME" >>SHA256SUMS.txt
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$ZIP_NAME" >>SHA256SUMS.txt
    else
        powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 '$ZIP_NAME').Hash + '  $ZIP_NAME'" >>SHA256SUMS.txt
    fi
)

echo "package-windows: wrote $ZIP_PATH"
echo "$STAGING"
