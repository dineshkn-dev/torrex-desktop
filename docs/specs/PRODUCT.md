# Torrin product specification

What the **current macOS release** does. Version **0.3.0** (see [CHANGELOG.md](../../CHANGELOG.md)). Planned work: [ROADMAP.yaml](../tracker/ROADMAP.yaml).

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
- **Pause all / resume all**; row menu and detail **More**: Reveal in Finder, copy magnet
- **Shortcuts:** Find, Space (pause/resume), Delete (remove)
- Status bar: **free space** on download volume
- **Resizable** master–detail split (width remembered)
- Overview and Files tabs; **appearance** (system / light / dark, accent colors)
- **Drag-and-drop** magnets and `.torrent` files
- **In-app notification** on download complete

### Distribution

- macOS **`.app`** and release **`.dmg`**
- Release artifacts: **SHA-256**, **SPDX SBOM**, **cosign** signatures

## Platform

- **Supported:** macOS (Apple Silicon and Intel per release CI)
- **Not yet:** Windows, Linux installers

## QA

[Release runbook](../runbooks/release.md) · [Release QA checklist](../runbooks/release-qa.md)
