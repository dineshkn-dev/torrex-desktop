# Torrin — contributor guide

[README.md](README.md) · [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) (architecture + release)

```bash
./scripts/bootstrap.sh
./scripts/verify.sh
```

## Repository map

| Path | Role |
|------|------|
| `src/core/` | `torrin_core` — libtorrent (**no Qt**) |
| `src/models/` | Qt models for QML |
| `src/app/` | `AppController`, QML |
| `include/torrin/` | Public C++ API |
| `tests/` | gtest |
| `scripts/` | bootstrap, verify, package-* |

## Invariants

1. **`torrin_core` must not include Qt** — `scripts/check-core-no-qt.sh`
2. **All libtorrent calls on the engine thread**
3. **QML binds to snapshots** — never `torrent_handle` in QML
4. **No secrets in the repo**
5. **User-visible changes** — `CHANGELOG.md` (+ README if needed)

## Sensitive paths

Review before changing: `cmake/DeployQt.cmake`, `.github/workflows/release.yml`, `vcpkg-configuration.json`.
