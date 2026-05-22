# Torrex

Open-source BitTorrent client for **macOS** (v0.1 focus), built with **C++20**, **libtorrent 2.x**, and **Qt 6 Quick (QML)**. Windows/Linux support is planned later; CI currently builds **macOS only** to keep feedback loops fast.

## Features (roadmap)

- Magnet and `.torrent` add, pause/resume, file priorities
- Modern QML UI with dark/light theme
- Fast-resume, bandwidth limits, cross-platform releases

See [docs/specs/MVP.md](docs/specs/MVP.md) and [docs/tracker/ROADMAP.yaml](docs/tracker/ROADMAP.yaml).

## Quick start

**Requirements:** CMake 3.24+, Ninja, C++20 compiler, Git.

**macOS (Homebrew):** `brew install cmake ninja pkg-config autoconf autoconf-archive automake libtool`

**macOS (Qt via vcpkg):** Full **Xcode** from the App Store is required (Command Line Tools alone are not enough). After install: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

```bash
./scripts/bootstrap.sh   # clones vcpkg, installs deps (first run: 30–60 min)
./scripts/verify.sh      # docs check + build + tests
./build/dev/bin/torrex   # run app

**Appearance:** Torrex follows **System Settings → Appearance** (light or dark). If the window looks white, macOS is in Light Mode; switch to Dark or Auto to get the dark theme.
```

Set `VCPKG_ROOT` if vcpkg lives outside the repo:

```bash
export VCPKG_ROOT=~/vcpkg
```

## For AI agents

Read [AGENTS.md](AGENTS.md) first.

## Architecture

- `torrex_core` — libtorrent session (no Qt)
- `torrex_models` — Qt models for QML
- `torrex` — Qt Quick application

ADRs: [docs/architecture/](docs/architecture/).

## License

GPL-3.0-or-later — see [LICENSE](LICENSE). libtorrent is BSD-licensed.

## Security

Report issues per [SECURITY.md](SECURITY.md). Use Torrex only for content you have the right to download or share.
