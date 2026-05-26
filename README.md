# Torrin

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/dineshkn-dev/torrin?label=release)](https://github.com/dineshkn-dev/torrin/releases/latest)
[![CI](https://img.shields.io/github/actions/workflow/status/dineshkn-dev/torrin/ci.yml?branch=main&label=CI)](https://github.com/dineshkn-dev/torrin/actions/workflows/ci.yml)

**Torrin** is an open-source **BitTorrent client** for **macOS**, **Windows**, and **Linux**, built with **Qt 6 Quick** and **libtorrent 2.x**: fast-resume, modern list UX, no ads, and no bundled telemetry ([ADR-003](docs/architecture/ADR-003-security.md)).

<p align="center">
  <a href="https://github.com/dineshkn-dev/torrin/releases/latest">
    <img src="https://img.shields.io/badge/Download-latest%20release-3390ec?style=for-the-badge" alt="Download latest release">
  </a>
</p>

<p align="center">
  <img src="docs/assets/torrin-dark.png" alt="Torrin dark mode — torrent list and detail" width="820">
</p>
<p align="center">
  <img src="docs/assets/torrin-light.png" alt="Torrin light mode" width="820">
</p>

## Why Torrin?

- **Native Qt Quick UI** — not Electron; C++20 + libtorrent 2.x
- **Privacy-first** — no telemetry by default; data stays on your machine
- **Trustworthy releases** — SHA-256 checksums, cosign signatures; SPDX SBOM on macOS
- **GPL-3.0** — inspectable source, no ads

## Features

- Magnet and `.torrent` add, pause, resume, remove, stop/resume seeding
- Search and sort list; filters; resizable master–detail UI
- File priorities, sequential download, force recheck / reannounce
- Bandwidth limits, port, DHT/UPnP, proxy; light/dark appearance
- Drag-and-drop, fast-resume, completion notifications

Details: [docs/specs/PRODUCT.md](docs/specs/PRODUCT.md). Roadmap: [docs/planning/FUTURE.md](docs/planning/FUTURE.md).

## Install

Download from **[Releases](https://github.com/dineshkn-dev/torrin/releases/latest)** for your platform:

| Platform | File | Install |
|----------|------|---------|
| **macOS** | `Torrin-*-macos-*.dmg` | Open the disk image, drag **Torrin** to **Applications**. If Gatekeeper blocks the app, use **System Settings → Privacy & Security → Open Anyway** until [notarized builds](docs/planning/FUTURE.md#production-macos) ship. |
| **Windows** | `Torrin-*-windows-x64.zip` | Extract the zip and run `torrin.exe`. Windows may show SmartScreen for unsigned builds. |
| **Linux** | `Torrin-*-linux-x64.tar.gz` | Extract and run `usr/bin/torrin` from the archive (Qt XCB bundled). |

Verify downloads with `SHA256SUMS.txt` and cosign `.sig` / `.crt` files attached to the release.

### Build from source

**Requirements:** CMake 3.24+, Ninja, C++20, Git, [vcpkg](https://vcpkg.io/) (manifest mode).

| OS | Extra tooling |
|----|----------------|
| macOS | Full **Xcode**, Homebrew deps — see [AGENTS.md](AGENTS.md) |
| Windows | Visual Studio 2022 build tools, `run-vcpkg` in CI |
| Linux | `ninja`, Mesa/XCB dev packages — see [`.github/workflows/ci.yml`](.github/workflows/ci.yml) |

```bash
export VCPKG_ROOT=~/vcpkg   # after ./scripts/bootstrap.sh on macOS
cmake --preset dev
cmake --build --preset dev
# macOS: ./scripts/run-dev.sh
# Win/Linux: ./build/dev/bin/torrin or torrin.exe
```

## Architecture

- `torrin_core` — libtorrent session (no Qt)
- `torrin_models` — Qt models for QML
- `torrin` — Qt Quick app

See [docs/architecture/](docs/architecture/) and [AGENTS.md](AGENTS.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) · [AGENTS.md](AGENTS.md) · [docs/CONVENTIONS.md](docs/CONVENTIONS.md)

## License

GPL-3.0-or-later — [LICENSE](LICENSE). libtorrent is BSD-licensed.

## Security

[SECURITY.md](SECURITY.md) — use Torrin only for content you have the right to download or share.
