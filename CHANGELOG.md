# Changelog

All notable changes to Torrin are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

Nothing yet — see [docs/planning/FUTURE.md](docs/planning/FUTURE.md).

## [0.2.0] - 2026-05-25

### Added

- Stop seeding and resume seeding per torrent
- Force recheck and force reannounce from the detail pane
- Detail overview metrics: peers, seeds, connections, ETA, upload ratio, and accurate total size
- Redesigned torrent detail hero, speed cards, segmented Overview/Files tabs, and file list with per-file progress
- Copy info hash from the overview pane

### Changed

- Torrent action controls use neutral chips with leading symbols (no per-action tint)
- Paused torrents show blank transfer rates and clearer ETA/status labels
- Settings gear uses a vector icon (fixes emoji rendering as “8” on macOS)

### Fixed

- Files tab list height in the detail pane (files visible again)
- QML size overflow for large torrent totals
- Release packaging path for `torrin.app` bundle name

## [0.1.0] - 2026-05-22

### Added

- macOS client: magnet and `.torrent` add, pause, resume, remove
- Master–detail UI with filters, Overview and Files tabs
- File priorities and sequential download per torrent
- Settings: bandwidth limits, listen port, DHT/UPnP, SOCKS5/HTTP proxy
- Fast-resume across app restarts
- Drag-and-drop, in-app download-complete notifications
- Release `.dmg` with SHA-256 checksums, SPDX SBOM, and cosign signatures
