# Torrin

Open-source BitTorrent client for **macOS**, built with **C++20**, **libtorrent 2.x**, and **Qt 6 Quick**.

## Features

- Magnet and `.torrent` add, pause, resume, remove, stop/resume seeding
- Search and sort list; filters; resizable master–detail UI
- File priorities, sequential download, force recheck / reannounce
- Bandwidth limits, port, DHT/UPnP, proxy; system light/dark theme
- Drag-and-drop, fast-resume, completion notifications
- Signed release `.dmg` with SBOM ([Releases](https://github.com/dineshkn-dev/torrin/releases))

Details: [docs/specs/PRODUCT.md](docs/specs/PRODUCT.md). Roadmap: [docs/planning/FUTURE.md](docs/planning/FUTURE.md).

## Install and run

Download the latest `.dmg` from **Releases**, or build from source:

**Requirements:** CMake 3.24+, Ninja, C++20, Git, full **Xcode** on macOS.

```bash
brew install cmake ninja pkg-config autoconf autoconf-archive automake libtool
./scripts/bootstrap.sh
cmake --preset dev
cmake --build --preset dev
./scripts/run-dev.sh
```

Torrin follows macOS **Appearance** (Light / Dark / Auto). Optional: `export VCPKG_ROOT=~/vcpkg`.

## Architecture

- `torrin_core` — libtorrent session (no Qt)
- `torrin_models` — Qt models for QML
- `torrin` — Qt Quick app

See [docs/architecture/](docs/architecture/) and [AGENTS.md](AGENTS.md).

## Contributing

[AGENTS.md](AGENTS.md) · [docs/CONVENTIONS.md](docs/CONVENTIONS.md)

## License

GPL-3.0-or-later — [LICENSE](LICENSE). libtorrent is BSD-licensed.

## Security

[SECURITY.md](SECURITY.md) — use Torrin only for content you have the right to download or share.
