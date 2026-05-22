#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -z "${VCPKG_ROOT:-}" && -d "$ROOT/vcpkg" ]]; then
    export VCPKG_ROOT="$ROOT/vcpkg"
fi

if [[ -z "${VCPKG_ROOT:-}" ]]; then
    echo "VCPKG_ROOT not set. Run ./scripts/bootstrap.sh first."
    exit 1
fi

./scripts/validate-docs.sh
./scripts/check-core-no-qt.sh

cmake --preset dev
cmake --build --preset dev
ctest --preset dev --output-on-failure

echo "verify: OK"
