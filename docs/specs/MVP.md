# Torrex MVP specification (v0.1)

## Phase 0 {#phase-0}

- [x] `AGENTS.md`, `docs/INDEX.md`, ADRs 001–004 published
- [x] `docs/tracker/ROADMAP.yaml` present and valid
- [x] `scripts/bootstrap.sh` and `scripts/verify.sh` runnable
- [x] `scripts/validate-docs.sh` passes in CI
- [x] Empty `torrex_core` + `torrex` compile on **macOS** (Windows/Linux deferred)

## CI {#ci}

- [x] GitHub Actions: **macOS arm64** build (Windows/Ubuntu matrix deferred for v0.1)
- [x] Lint workflow (clang-format, cmake-format)
- [x] CodeQL and OpenSSF Scorecard workflows present

## Skeleton {#skeleton}

- [x] `SessionManager` starts/stops libtorrent session on worker thread
- [x] Minimal QML window loads
- [x] Unit tests for version and session smoke

## Torrent lifecycle {#torrent-lifecycle}

- [x] Add magnet URI and `.torrent` file
- [x] Pause, resume, remove (optional delete data)
- [x] Per-torrent save path on add (folder picker); global default remembered
- [ ] File priorities and sequential download
- [ ] Fast-resume across restarts

## Session / network

- [ ] Global download/upload limits
- [ ] Port, UPnP, proxy settings

## UI

- [x] Sidebar filters, torrent list, detail tabs (overview; files tab placeholder)
- [x] Dark/light theme (follows system appearance)
- [ ] Drag-and-drop and notifications

## Acceptance (v0.1 release)

- Download a legal Linux ISO via magnet and `.torrent`
- Restart app; torrents restore
- Release artifacts include SPDX SBOM and signed binaries (per runbook)
