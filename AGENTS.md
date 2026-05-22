# Torrex — Agent Guide

Single entry point for AI agents and contributors. Read this first, then follow links in order.

## Quick start

```bash
./scripts/bootstrap.sh    # once: vcpkg + preset + pre-commit
./scripts/verify.sh       # format check + configure + build + test
```

## Build (CMake presets)

| Preset | Use |
|--------|-----|
| `dev` | Local debug build |
| `ci-release` | CI / release-like build |
| `sanitize` | ASan + UBSan (dev only) |

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
```

**Toolchain:** `vcpkg.json` manifest mode. `CMAKE_TOOLCHAIN_FILE` is set in `CMakePresets.json` to `$env{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake`.

## Repository map

| Path | Role |
|------|------|
| `src/core/` | `torrex_core` — libtorrent session, **no Qt headers** |
| `src/models/` | Qt models → QML |
| `src/app/` | `main.cpp`, `AppController` |
| `src/ui/qml/` | Qt Quick UI |
| `include/torrex/` | Public C++ API only |
| `docs/` | Specs, ADRs, tracker — see [docs/INDEX.md](docs/INDEX.md) |
| `tests/` | gtest unit + integration |
| `scripts/` | bootstrap, verify, validate-docs |

## Invariants (do not violate)

1. **`torrex_core` must not include Qt** — enforced by `scripts/check-core-no-qt.sh`
2. **All `libtorrent` calls on the engine thread** — UI sends `TorrentCommand` only
3. **QML binds to snapshots** — never hold `torrent_handle` in QML
4. **No secrets in repo** — gitleaks runs on pre-commit
5. **Behavior change → update** `docs/specs/` + `docs/tracker/ROADMAP.yaml` in the same PR

## Tests

```bash
ctest --preset dev --output-on-failure
```

Fixtures: `tests/fixtures/` (legal redistributable samples only).

## Docs read order

1. This file
2. [docs/INDEX.md](docs/INDEX.md)
3. [docs/specs/MVP.md](docs/specs/MVP.md) for scope
4. [docs/tracker/ROADMAP.yaml](docs/tracker/ROADMAP.yaml) for progress
5. Relevant ADR under `docs/architecture/`

## Release

Tag `v*` on `main` triggers [.github/workflows/release.yml](.github/workflows/release.yml) (macOS `.dmg`, SBOM, cosign). See [docs/runbooks/release.md](docs/runbooks/release.md).

## Do not touch without ADR

- `cmake/DeployQt.cmake` — packaging paths (coordinate with release runbook)
- `.github/workflows/release.yml` — signing / SBOM (coordinate with ADR-003)
- `vcpkg-configuration.json` baseline pin

## License

GPL-3.0 — see [LICENSE](LICENSE).
