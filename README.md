# Torrin

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/dineshkn-dev/torrin?label=release)](https://github.com/dineshkn-dev/torrin/releases/latest)
[![CI](https://img.shields.io/github/actions/workflow/status/dineshkn-dev/torrin/ci.yml?branch=main&label=CI)](https://github.com/dineshkn-dev/torrin/actions/workflows/ci.yml)

Open-source **BitTorrent client** for **macOS**, **Windows**, and **Linux** — **Qt 6 Quick** UI, **libtorrent 2.x**, no ads, no bundled telemetry.

<p align="center">
  <a href="https://github.com/dineshkn-dev/torrin/releases/latest">
    <img src="https://img.shields.io/badge/Download-latest%20release-3390ec?style=for-the-badge" alt="Download latest release">
  </a>
</p>

<p align="center">
  <img src="docs/assets/torrin-dark.png" alt="Torrin dark mode" width="820">
</p>

## Features

- Magnet and `.torrent` add, pause, resume, remove, stop/resume seeding
- Search, sort, filters, resizable master–detail UI
- File priorities, sequential download, force recheck / reannounce
- Bandwidth limits, port, DHT/UPnP, proxy; light/dark appearance
- Drag-and-drop, fast-resume, completion notifications

## Install

Download from **[Releases](https://github.com/dineshkn-dev/torrin/releases/latest)**:

| Platform | File | Notes |
|----------|------|--------|
| macOS | `.dmg` | Drag to Applications; use **Open Anyway** if Gatekeeper blocks |
| Windows | `.zip` (x64) | Run `torrin.exe` from the extracted folder |
| Linux | `.tar.gz` (x64) | Run `usr/bin/torrin` from the archive |

Verify with `SHA256SUMS.txt` and cosign files on the release page.

## Build from source

```bash
./scripts/bootstrap.sh
cmake --preset dev && cmake --build --preset dev
ctest --preset dev
./scripts/run-dev.sh   # macOS; see AGENTS.md for other OSes
```

## Architecture

Qt Quick UI and models on the **UI thread**; libtorrent runs on a **worker thread**. Commands go in, throttled snapshots come out — see **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**.

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md) · [AGENTS.md](AGENTS.md) · [CHANGELOG.md](CHANGELOG.md)

## License

GPL-3.0-or-later — [LICENSE](LICENSE). Use Torrin only for content you have the right to share ([SECURITY.md](SECURITY.md)).
