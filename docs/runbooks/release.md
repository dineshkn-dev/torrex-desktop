# Release

## Before tagging

1. `./scripts/verify.sh` passes locally (or CI green on `main`).
2. Bump `include/torrin/version.hpp`, `CMakeLists.txt`, `vcpkg.json`, and `CHANGELOG.md`.
3. Smoke-test a package on at least one OS (launch, add legal torrent, pause/resume, quit/reopen).

## Tag

```bash
git tag v1.0.0
git push origin v1.0.0
```

Workflow **Release** (`release.yml`) publishes per-platform archives, `SHA256SUMS.txt`, and cosign signatures (~30–90 minutes).

## Local package (optional)

```bash
cmake --preset ci-release && cmake --build --preset ci-release
./scripts/package-macos.sh build/ci-release    # or package-windows.sh / package-linux.sh
```

## Rollback

Mark the GitHub Release as draft, delete the tag if needed, fix on `main`, re-tag.
