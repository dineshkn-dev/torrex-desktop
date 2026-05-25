# Torrin product specification (v0.1)

Torrin v0.1 is a **macOS** BitTorrent client. This document describes what the shipped product does today.

## Capabilities

### Torrents

- Add downloads via **magnet link** or **`.torrent` file**, with a **file checklist** before starting (select which files to download)
- **Pause**, **resume**, **stop seeding** / **resume seeding** (disable upload on completed torrents without pausing), and **remove** (optionally delete data on disk)
- **Force recheck** and **force reannounce** per torrent
- **Per-torrent save folder** when adding; **default folder** in Settings
- **File priorities** (skip / low / normal / high) and **sequential download** per torrent
- **Fast-resume**: torrent list and progress restore after quit and relaunch

### Network and settings

- Global **download and upload** rate limits
- **Listen port**, **UPnP**, **NAT-PMP**, **DHT**, and **LSD** toggles
- Optional **SOCKS5** or **HTTP** proxy

### User interface

- Sidebar **filters** (All, Downloading, Seeding, Paused)
- **Master–detail** layout with Overview and Files tabs
- **Appearance** settings: system / light / dark / **AMOLED** (true black, neutral grays — unchanged by accent) and **accent color** (blue, teal, violet, rose, orange, green) for controls and highlights
- **Drag-and-drop** magnets and `.torrent` files onto the window
- **In-app notification** when a download completes

### Distribution

- macOS **`.app` bundle** and release **`.dmg`**
- Release artifacts include **SHA-256 checksums**, **SPDX SBOM**, and **cosign** signatures

## Platform

- **Supported:** macOS (Apple Silicon and Intel via universal/fat builds as provided by release CI)
- **Not yet:** Windows, Linux installers

## Quality assurance

Release verification steps: [release runbook](../runbooks/release.md) and [release QA checklist](../runbooks/release-qa.md).
