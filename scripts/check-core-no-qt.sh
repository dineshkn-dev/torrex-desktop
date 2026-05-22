#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if rg -i '#include\s*<Q|#include\s*"Q' src/core include/torrex 2>/dev/null; then
    echo "check-core-no-qt: Qt headers found in torrex_core"
    exit 1
fi

echo "check-core-no-qt: OK"
