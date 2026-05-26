# Torrin — contributor guide

Build and test: see [README.md](README.md). Architecture: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Quick start

```bash
./scripts/bootstrap.sh    # once: vcpkg + preset + pre-commit
./scripts/verify.sh       # format check + configure + build + test
```

## Build

| Preset | Use |
|--------|-----|
| `dev` | Local debug build |
| `ci-release` | Release-like build and packaging (all platforms) |
| `sanitize` | ASan + UBSan |

Releases: tag `v*` → `release.yml` (macOS `.dmg`, Windows `.zip`, Linux `.tar.gz`). PRs: `ci.yml`.

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
```

**Toolchain:** `vcpkg.json` manifest mode via `CMakePresets.json`.

## Repository map

| Path | Role |
|------|------|
| `src/core/` | `torrin_core` — libtorrent session (**no Qt**) |
| `src/models/` | Qt models for QML |
| `src/app/` | Application entry and `AppController` |
| `src/app/qml/` | Qt Quick UI |
| `include/torrin/` | Public C++ API |
| `docs/` | [ARCHITECTURE.md](docs/ARCHITECTURE.md), [release runbook](docs/runbooks/release.md) |
| `tests/` | gtest |
| `scripts/` | bootstrap, verify, validate-docs |

## Invariants

1. **`torrin_core` must not include Qt** — `scripts/check-core-no-qt.sh`
2. **All libtorrent calls on the engine thread** — UI uses queued commands only
3. **QML binds to snapshots** — never expose `torrent_handle` to QML
4. **No secrets in the repo**
5. **User-visible changes** — update `CHANGELOG.md` and README if needed

## Release

Tag `v*` triggers [.github/workflows/release.yml](.github/workflows/release.yml). See [docs/runbooks/release.md](docs/runbooks/release.md).

## Sensitive paths

Get maintainer review before changing: `cmake/DeployQt.cmake`, `.github/workflows/release.yml`, `vcpkg-configuration.json`.

## License

GPL-3.0 — see [LICENSE](LICENSE).
