# ADR-004: Documentation and work tracking

## Status

Accepted

## Decision

Four-layer doc system:

1. `AGENTS.md` — agent/human entry
2. `docs/specs/` — requirements and acceptance criteria
3. `docs/tracker/ROADMAP.yaml` — structured progress (CI-validated)
4. GitHub Issues/Projects — live work status

Avoid freeform-only `TODO.md` files as source of truth.

## Enforcement

`scripts/validate-docs.sh` on every PR.
