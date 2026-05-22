# ADR-003: Security baseline

## Status

Accepted

## Decision

- Threat model in `docs/security/THREAT_MODEL.md` maintained with releases.
- Input limits on `.torrent` size and magnet URI validation before parse.
- No telemetry by default in v0.1.
- CI: CodeQL, OSV-Scanner, gitleaks, OpenSSF Scorecard.
- Releases: SPDX SBOM + cosign signing (Phase 5).
- macOS v1: App Sandbox disabled; document entitlements in `packaging/macos/`.

## Supply chain

- Pin vcpkg baseline in `vcpkg-configuration.json`.
- Renovate for dependency update PRs with CI gates.
