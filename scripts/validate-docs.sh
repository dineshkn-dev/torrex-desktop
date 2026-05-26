#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

required=(
    AGENTS.md
    docs/ARCHITECTURE.md
    docs/runbooks/release.md
    SECURITY.md
)

for f in "${required[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "validate-docs: missing $f"
        exit 1
    fi
done

echo "validate-docs: OK"
