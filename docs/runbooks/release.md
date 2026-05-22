# Release runbook

## Preconditions

- `main` green on CI (macOS build + tests)
- `docs/tracker/ROADMAP.yaml` reflects shipped features
- `CHANGELOG.md` updated for the version

## Cut a release

1. Merge all release work to `main`.
2. Update `include/torrex/version.hpp` and `CHANGELOG.md` if the version changes.
3. Tag and push:

```bash
git tag v0.1.0
git push origin v0.1.0
```

4. GitHub Actions **Release** workflow (`release.yml`) on tag `v*`:
   - Builds with `ci-release` preset
   - Produces `Torrex-<version>-macos-<arch>.dmg` and `SHA256SUMS.txt`
   - Generates SPDX SBOM (`torrex.spdx.json`)
   - Signs artifacts with [cosign](https://docs.sigstore.dev/) (keyless in CI)
   - Publishes a GitHub Release with attached assets

## Local packaging (macOS)

```bash
cmake --preset ci-release
cmake --build --preset ci-release
./scripts/package-macos.sh build/ci-release
open build/ci-release/staging/*.dmg
```

Run the app from the bundle during development:

```bash
open build/dev/bin/Torrex.app
```

## Optional: notarization

Apple notarization and stapling are **not** automated in v0.1. To ship outside the Mac App Store:

1. Sign `Torrex.app` with a Developer ID Application certificate.
2. Notarize the `.dmg` with `notarytool` and staple the ticket.
3. Store signing credentials in a GitHub **environment** named `release` and extend `release.yml` when ready.

## Rollback

Delete or mark the GitHub Release as draft, remove the tag if needed, and fix forward on `main`.
