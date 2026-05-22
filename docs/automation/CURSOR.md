# Cursor automation recipes

## PR CI babysit

When a PR fails CI:

1. Read the failed job log.
2. Fix only issues in scope of the branch.
3. Run `./scripts/verify.sh` locally.
4. Push and re-check CI.

Do not weaken CI checks to make them pass.

## Dependency PRs (Renovate)

1. Let CI run on the Renovate branch.
2. If vcpkg baseline bump fails, check release notes for Qt/libtorrent breaking changes.
3. Merge when matrix is green.

## Release (maintainers)

Follow [runbooks/release.md](../runbooks/release.md).
