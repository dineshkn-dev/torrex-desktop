# ADR-004: Documentation and work tracking

## Status

Accepted

## Decision

Documentation layers:

1. `docs/specs/PRODUCT.md` — what the shipped product does
2. `docs/planning/FUTURE.md` — next major themes (human-readable)
3. `docs/tracker/ROADMAP.yaml` — planned milestones (CI-validated)
4. `AGENTS.md` — contributor build and layout guide

Avoid freeform-only `TODO.md` files as source of truth for scope.

## Enforcement

`scripts/validate-docs.sh` on every PR.
