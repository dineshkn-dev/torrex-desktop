# Torrin product specification

What the **current release** ships. Version **1.0.0** (see [CHANGELOG.md](../../CHANGELOG.md)). Planned work: [ROADMAP.yaml](../tracker/ROADMAP.yaml).

## Capabilities

### Torrents

- Add via **magnet** or **`.torrent`**, with a **file checklist** before starting
- **Pause**, **resume**, **stop seeding** / **resume seeding**, **remove** (optional delete data)
- **Force recheck** and **force reannounce**
- **Per-torrent save folder**; **default folder** in Settings
- **File priorities** and **sequential download**
- **Fast-resume** after quit and relaunch

### Network and settings

- Global **download / upload** limits
- **Listen port**, **UPnP**, **NAT-PMP**, **DHT**, **LSD**
- Optional **SOCKS5** or **HTTP** proxy

### User interface

- Sidebar **filters** (All, Downloading, Seeding, Paused)
- **Search** by name, info hash, or save path
- **Sort** by name or date created (ascending / descending)
- **ETA** in list rows
- **Pause all / resume all**; row menu and detail **More**: reveal in file manager, copy magnet
- **Shortcuts:** Find, Space (pause/resume), Delete (remove) (macOS-focused shortcuts)
- Status bar: **free space** on download volume
- **Resizable** master–detail split (width remembered)
- Overview and Files tabs; **appearance** (system / light / dark on macOS; AMOLED-style dark palette)
- **Drag-and-drop** magnets and `.torrent` files (where the platform supports it)
- **In-app notification** on download complete

### Distribution

| Platform | Artifact | Notes |
|----------|----------|--------|
| macOS | `.dmg` | Apple Silicon / Intel per CI runner |
| Windows | `.zip` (x64) | Portable folder, `windeployqt` |
| Linux | `.tar.gz` (x64) | Portable tree, Qt XCB plugin bundled |

All platforms: **SHA-256** checksums, **cosign** signatures; macOS also includes **SPDX SBOM**.

## Platform

- **Supported:** macOS, Windows (x64), Linux (x64)
- **Not yet:** ARM Windows, ARM Linux packages, notarized macOS, OS installers (MSI/deb), system tray on Win/Linux

## QA

[Release runbook](../runbooks/release.md) · [Release QA checklist](../runbooks/release-qa.md)
