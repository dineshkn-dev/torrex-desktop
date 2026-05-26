# ADR-006: Cross-platform release (v1.0)

## Status

Accepted

## Context

[ADR-005](ADR-005-macos-first-ci.md) limited CI to macOS-only releases while the stack (Qt 6 Quick, libtorrent, C++20) is cross-platform. Users on Windows and Linux need installable artifacts; contributors need multi-OS CI to catch regressions before tag.

## Decision

- **Ship** portable releases on tag `v*`:
  - macOS: `.dmg` (existing `package-macos.sh`)
  - Windows: `.zip` with `windeployqt`
  - Linux: `.tar.gz` with `linuxdeploy` + Qt plugin
- **CI:** `ci.yml` on `main` / PRs — configure, build, test on all three OSes (no packaging).
- **Release:** `release.yml` — parallel build+package jobs, `publish` job merges artifacts, cosign, GitHub Release.
- **UI:** platform-appropriate “reveal in file manager” label; core remains Qt-free.
- **Deferred:** Windows code signing, Linux `.deb`/AppImage, notarization ([FUTURE.md](../planning/FUTURE.md#production-macos)), tray/notifications ([FUTURE.md](../planning/FUTURE.md#cross-platform) M-204).

## Consequences

- Positive: One tag produces three downloads; PR CI catches platform breaks early.
- Negative: Release workflow wall time and vcpkg cost increase (~3×); first Windows/Linux releases may need runner-specific fixes.
