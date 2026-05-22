# Torrex MVP specification (v0.1)

## Phase 0 {#phase-0}

- [ ] `AGENTS.md`, `docs/INDEX.md`, ADRs 001–004 published
- [ ] `docs/tracker/ROADMAP.yaml` present and valid
- [ ] `scripts/bootstrap.sh` and `scripts/verify.sh` runnable
- [ ] `scripts/validate-docs.sh` passes in CI
- [ ] Empty `torrex_core` + `torrex` compile on **macOS** (Windows/Linux deferred)

## CI {#ci}

- [ ] GitHub Actions: **macOS arm64** build (Windows/Ubuntu matrix deferred for v0.1)
- [ ] Lint workflow (clang-format, cmake-format)
- [ ] CodeQL and OpenSSF Scorecard workflows present

## Skeleton {#skeleton}

- [ ] `SessionManager` starts/stops libtorrent session on worker thread
- [ ] Minimal QML window loads
- [ ] Unit tests for version and session smoke

## Torrent lifecycle {#torrent-lifecycle}

- [ ] Add magnet URI and `.torrent` file
- [ ] Pause, resume, remove (optional delete data)
- [ ] Global and per-torrent save path
- [ ] File priorities and sequential download
- [ ] Fast-resume across restarts

## Session / network

- [ ] Global download/upload limits
- [ ] Port, UPnP, proxy settings

## UI

- [ ] Sidebar filters, torrent list, detail tabs
- [ ] Dark/light theme
- [ ] Drag-and-drop and notifications

## Acceptance (v0.1 release)

- Download a legal Linux ISO via magnet and `.torrent`
- Restart app; torrents restore
- Release artifacts include SPDX SBOM and signed binaries (per runbook)
