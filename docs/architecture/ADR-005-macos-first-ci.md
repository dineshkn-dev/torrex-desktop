# ADR-005: macOS-first product and CI

## Status

Accepted

## Context

Cross-platform CI (macOS + Windows + Ubuntu) compiles Qt and libtorrent from source via vcpkg on each runner. A single workflow run can exceed 30–40 minutes and triple CI cost while v0.1 only targets the macOS app.

## Decision

- **Product focus (v0.1):** ship and iterate on the **macOS** app first.
- **CI:** one `build-macos` job on `macos-14`; keep fast `validate-docs` on Ubuntu.
- **Codebase:** remain structurally cross-platform (Qt6 QML); re-enable Windows/Linux CI when release scope expands.

## Consequences

- Positive: Faster PR feedback (~one vcpkg/Qt build per push instead of three).
- Negative: Regressions on Windows/Linux are not caught until matrix is restored.
