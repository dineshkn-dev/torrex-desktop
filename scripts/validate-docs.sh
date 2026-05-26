#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for f in AGENTS.md docs/ARCHITECTURE.md SECURITY.md; do
    if [[ ! -f "$f" ]]; then
        echo "validate-docs: missing $f"
        exit 1
    fi
done

echo "validate-docs: OK"
