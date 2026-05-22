# Release runbook (draft)

## Preconditions

- `main` green on CI (all platforms)
- `docs/tracker/ROADMAP.yaml` reflects shipped features
- `CHANGELOG.md` updated

## Steps

1. Tag `v0.1.0` on `main`
2. `release.yml` builds artifacts, generates SBOM, signs with cosign
3. macOS: notarize `.dmg` (secrets in GitHub environment `release`)
4. Publish GitHub Release with checksums

## Rollback

Remove pre-release tag and mark GitHub Release as draft; announce in README if needed.
