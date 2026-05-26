# Release runbook

## Preconditions

- `scripts/verify.sh` passes on the release commit locally (macOS) or CI green on `main`
- `CHANGELOG.md` and `include/torrin/version.hpp` updated for the version
- [release-qa.md](release-qa.md) checklist completed on at least one platform

## Cut a release

1. Merge all release work to `main`.
2. Confirm version in `include/torrin/version.hpp`, `CMakeLists.txt`, and `vcpkg.json`.
3. Tag and push:

```bash
git tag v1.0.0
git push origin v1.0.0
```

4. GitHub Actions **Release** workflow (`release.yml`) on tag `v*`:
   - **macOS:** `Torrin-<version>-macos-<arch>.dmg`, SPDX SBOM, cosign
   - **Windows:** `Torrin-<version>-windows-x64.zip`
   - **Linux:** `Torrin-<version>-linux-x64.tar.gz`
   - Combined `SHA256SUMS.txt` and cosign files on the GitHub Release

Wall time is typically 30–90 minutes (vcpkg builds Qt/libtorrent per runner).

## Local packaging

### macOS

```bash
cmake --preset ci-release
cmake --build --preset ci-release
./scripts/package-macos.sh build/ci-release
open build/ci-release/staging/*.dmg
```

### Windows (Git Bash or MSYS)

```bash
cmake --preset ci-release
cmake --build --preset ci-release
./scripts/package-windows.sh build/ci-release
```

### Linux

```bash
cmake --preset ci-release
cmake --build --preset ci-release
./scripts/package-linux.sh build/ci-release
tar -tzf build/ci-release/staging/Torrin-*-linux-x64.tar.gz | head
```

## Optional: macOS notarization

Apple notarization and stapling are **not** automated yet. See [FUTURE.md](../planning/FUTURE.md#production-macos).

## Rollback

Delete or mark the GitHub Release as draft, remove the tag if needed, and fix forward on `main`.
