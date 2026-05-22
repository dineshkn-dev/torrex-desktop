#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -z "${VCPKG_ROOT:-}" ]]; then
    if [[ ! -d "$ROOT/vcpkg" ]]; then
        echo "Cloning vcpkg..."
        git clone --depth 1 https://github.com/microsoft/vcpkg.git "$ROOT/vcpkg"
    fi
    export VCPKG_ROOT="$ROOT/vcpkg"
fi

export VCPKG_ROOT
echo "VCPKG_ROOT=$VCPKG_ROOT"

"$VCPKG_ROOT/bootstrap-vcpkg.sh" -disableMetrics

if ! command -v cmake >/dev/null 2>&1; then
    echo "cmake is required. Install via: brew install cmake ninja"
    exit 1
fi

if ! command -v ninja >/dev/null 2>&1; then
    echo "ninja is required. Install via: brew install ninja"
    exit 1
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
    if ! xcodebuild -version &>/dev/null; then
        echo "ERROR: Full Xcode is required to build Qt via vcpkg on macOS."
        echo "Install Xcode from the App Store, then run:"
        echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
        exit 1
    fi
fi

if [[ "$(uname -s)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    # vcpkg transitive ports (libb2, etc.) need autotools on macOS
    brew_packages=(pkg-config autoconf autoconf-archive automake libtool)
    for pkg in "${brew_packages[@]}"; do
        if ! brew list "$pkg" &>/dev/null; then
            echo "Installing $pkg via Homebrew..."
            brew install "$pkg"
        fi
    done
fi

cmake --preset dev

if command -v pre-commit >/dev/null 2>&1; then
    pre-commit install
else
    echo "Optional: pip install pre-commit && pre-commit install"
fi

echo "Bootstrap complete. Run: ./scripts/verify.sh"
