# ADR-005: macOS-first product and CI

## Status

Accepted

## Context

Cross-platform CI (macOS + Windows + Ubuntu) compiles Qt and libtorrent from source via vcpkg on each runner. A single workflow run can exceed 30–40 minutes and triple CI cost while v0.1 only targets the macOS app.

## Decision

- **Product focus (v0.1):** ship and iterate on the **macOS** app first.
- **GitHub Actions:** `release.yml` only (tag `v*` / manual dispatch); no per-push PR CI.
- **Codebase:** remain structurally cross-platform (Qt6 QML); add PR CI when release scope expands.

## Consequences

- Positive: No vcpkg/Qt build on every push; contributors use `scripts/verify.sh` locally.
- Negative: Regressions are caught at release time or via local verify, not automatically on PRs.
