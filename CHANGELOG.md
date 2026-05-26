# Changelog

All notable changes to Torrin are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

Nothing yet — see [docs/planning/FUTURE.md](docs/planning/FUTURE.md).

## [0.3.0] - 2026-05-26

### Added

- Search torrent list by name, info hash, or save path
- Sort list by **name** or **date created** (ascending / descending)
- ETA in list rows; **pause all** and **resume all** in list actions menu
- **Reveal in Finder** and **copy magnet link** from row menu and detail **More** menu
- Keyboard shortcuts: **Find** (search), **Space** (pause/resume), **Delete** (remove)
- Free-space line on the download volume in the list status bar
- Resizable master–detail split with remembered list width; responsive layout in narrow panes
- Modern list toolbar: pill search field, segmented sort control, filter chips

### Changed

- Single **dark** appearance (AMOLED-style); system mode follows macOS with the same palette
- Consolidated detail action chips (pause/resume and stop/resume seeding toggles)
- Improved scroll feel (rubber-band overshoot, balanced mouse vs trackpad wheel)
- Repository and branding cleanup (`torrin` naming, leaner docs)

### Fixed

- Sort/filter controls wrap inside the list pane when the splitter is narrow (no clipping under detail pane)
- Search field loses focus when clicking elsewhere in the app
- Sort segment bar layout (sliding indicator no longer renders as a stray pill)

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
