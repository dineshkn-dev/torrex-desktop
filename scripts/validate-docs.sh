#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

required=(
    AGENTS.md
    docs/INDEX.md
    docs/CONVENTIONS.md
    docs/specs/MVP.md
    docs/tracker/ROADMAP.yaml
    docs/architecture/ADR-001-stack.md
    SECURITY.md
)

for f in "${required[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "validate-docs: missing $f"
        exit 1
    fi
done

# ROADMAP must reference existing spec files
while IFS= read -r spec; do
    path="${spec#docs/}"
    if [[ ! -f "docs/$path" && ! -f "$spec" ]]; then
        # allow anchors like docs/specs/MVP.md#phase-0
        base="${spec%%#*}"
        base="${base#docs/}"
        if [[ ! -f "docs/$base" ]]; then
            echo "validate-docs: ROADMAP references missing spec: $spec"
            exit 1
        fi
    fi
done < <(grep -E 'spec: docs/' docs/tracker/ROADMAP.yaml | sed 's/.*spec: //' | cut -d# -f1)

echo "validate-docs: OK"
