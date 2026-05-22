# ADR-003: Security baseline

## Status

Accepted

## Decision

- Threat model in `docs/security/THREAT_MODEL.md` maintained with releases.
- Input limits on `.torrent` size and magnet URI validation before parse.
- No telemetry by default in v0.1.
- CI: macOS build + tests (`ci.yml`); release pipeline on version tags (`release.yml`).
- Local: gitleaks via pre-commit; format via `scripts/verify.sh`.
- Releases: SPDX SBOM + cosign signing (Phase 5).
- macOS v1: App Sandbox disabled; document entitlements in `packaging/macos/`.

## Supply chain

- Pin vcpkg baseline in `vcpkg-configuration.json`.
- Dependency updates reviewed manually; vcpkg baseline pinned.
