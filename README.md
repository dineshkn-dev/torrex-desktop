# Torrex

Open-source BitTorrent client for **macOS** (v0.1), built with **C++20**, **libtorrent 2.x**, and **Qt 6 Quick**.

## Features (v0.1)

- Magnet and `.torrent` add, pause, resume, remove
- File priorities and sequential download
- Bandwidth limits, port, DHT/UPnP, and proxy settings
- Master–detail UI, filters, system light/dark theme
- Drag-and-drop, fast-resume, completion notifications
- Signed release `.dmg` with SBOM (see [Releases](https://github.com/dineshkn-dev/torrex-desktop/releases))

Full list: [docs/specs/PRODUCT.md](docs/specs/PRODUCT.md).

## What's next

Planned milestones (notarized macOS distribution, Windows/Linux, advanced torrent features): [docs/planning/FUTURE.md](docs/planning/FUTURE.md).

## Install and run

Download the latest `.dmg` from **Releases**, or build from source:

**Requirements:** CMake 3.24+, Ninja, C++20, Git, full **Xcode** on macOS (for Qt via vcpkg).

```bash
brew install cmake ninja pkg-config autoconf autoconf-archive automake libtool
./scripts/bootstrap.sh   # first run may take 30–60 min (vcpkg + Qt)
cmake --preset dev
cmake --build --preset dev
open build/dev/bin/Torrex.app
```

Torrex follows your macOS **Appearance** (Light / Dark / Auto).

Optional: `export VCPKG_ROOT=~/vcpkg` if vcpkg is outside the repo.

## Architecture

- `torrex_core` — libtorrent session (no Qt)
- `torrex_models` — Qt models
- `torrex` — Qt Quick app

Details: [docs/architecture/](docs/architecture/).

## Contributing

See [AGENTS.md](AGENTS.md) and [docs/CONVENTIONS.md](docs/CONVENTIONS.md).

## License

GPL-3.0-or-later — see [LICENSE](LICENSE). libtorrent is BSD-licensed.

## Security

Report issues per [SECURITY.md](SECURITY.md). Use Torrex only for content you have the right to download or share.
