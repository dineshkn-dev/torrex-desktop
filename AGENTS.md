# Torrin — contributor guide

Build, test, and change the codebase. Product scope is in [docs/specs/PRODUCT.md](docs/specs/PRODUCT.md); planned work is in [docs/planning/FUTURE.md](docs/planning/FUTURE.md).

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

Releases: `release.yml` (tag `v*`) builds macOS `.dmg`, Windows `.zip`, Linux `.tar.gz`. PR CI: `ci.yml`.

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
| `docs/` | Product spec, planning, ADRs — [docs/INDEX.md](docs/INDEX.md) |
| `tests/` | gtest |
| `scripts/` | bootstrap, verify, validate-docs |

## Invariants

1. **`torrin_core` must not include Qt** — `scripts/check-core-no-qt.sh`
2. **All libtorrent calls on the engine thread** — UI uses queued commands only
3. **QML binds to snapshots** — never expose `torrent_handle` to QML
4. **No secrets in the repo**
5. **Behavior or scope changes** — update `docs/specs/PRODUCT.md` and/or `docs/planning/FUTURE.md` + `docs/tracker/ROADMAP.yaml`

## Release

Tag `v*` triggers [.github/workflows/release.yml](.github/workflows/release.yml). See [docs/runbooks/release.md](docs/runbooks/release.md).

## Sensitive paths

Coordinate with ADRs before changing: `cmake/DeployQt.cmake`, `.github/workflows/release.yml`, `vcpkg-configuration.json`.

## License

GPL-3.0 — see [LICENSE](LICENSE).
