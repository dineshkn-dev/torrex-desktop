# ADR-001: Technology stack

## Status

Accepted

## Context

Torrex is a cross-platform desktop BitTorrent client built from a greenfield repository. We need a mature protocol implementation and a modern UI that ships on macOS, Windows, and Linux.

## Decision

- **Language:** C++20 (application glue and engine wrapper)
- **Torrent engine:** libtorrent-rasterbar 2.0.x
- **UI:** Qt 6 Quick (QML) + Qt Quick Controls
- **Build:** CMake 3.24+ with vcpkg manifest mode
- **Persistence:** SQLite via Qt SQL (Phase 2+)
- **License:** GPL-3.0 for the application

Rust and Tauri were considered; rejected for v1 due to Qt6 integration maturity and libtorrent ecosystem fit (see plan: Language choice).

## Consequences

- Positive: Fast path to feature parity with proven stack (qBittorrent model).
- Negative: Manual memory safety discipline; mitigated by sanitizers and local/static checks.
- vcpkg build times are long; CI caches `vcpkg_installed`.
