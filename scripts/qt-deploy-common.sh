#!/usr/bin/env bash
# Shared helpers for finding Qt deploy tools and version string.
set -euo pipefail

torrin_version() {
    local root="$1"
    grep -E 'constexpr const char\* kVersion' "$root/include/torrin/version.hpp" \
        | sed -E 's/.*"([^"]+)".*/\1/'
}

# Usage: find_qt_deploy_tool <build_dir> <windeployqt|macdeployqt>
find_qt_deploy_tool() {
    local build_dir="$1"
    local tool="$2"
    local triplet
    for triplet in x64-windows arm64-osx x64-osx x64-linux; do
        local candidate
        for candidate in \
            "$build_dir/vcpkg_installed/$triplet/tools/Qt6/bin/$tool" \
            "$build_dir/vcpkg_installed/$triplet/tools/Qt6/bin/${tool}.exe" \
            "$build_dir/vcpkg_installed/$triplet/tools/qt6/bin/$tool" \
            "$build_dir/vcpkg_installed/$triplet/tools/qt6/bin/${tool}.exe"; do
            if [[ -x "$candidate" ]]; then
                echo "$candidate"
                return 0
            fi
        done
    done
    if command -v "$tool" >/dev/null 2>&1; then
        command -v "$tool"
        return 0
    fi
    return 1
}
