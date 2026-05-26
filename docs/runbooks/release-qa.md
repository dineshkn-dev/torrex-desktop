# Release QA checklist

Use before or after publishing a **tagged** release build.

## Build under test

Use the GitHub Release assets for the tag, or a local package:

| Platform | Command |
|----------|---------|
| macOS | `./scripts/package-macos.sh build/ci-release` |
| Windows | `./scripts/package-windows.sh build/ci-release` |
| Linux | `./scripts/package-linux.sh build/ci-release` |

## Checklist (each platform you ship)

- [ ] App launches without missing Qt/platform plugin errors
- [ ] Add a **legal** torrent via magnet and via `.torrent`
- [ ] Pause, resume, remove (with and without delete data)
- [ ] Files tab: change priority; toggle sequential download
- [ ] Settings persist after restart (folder, limits, proxy if used)
- [ ] Quit and reopen: torrents restore from fast-resume
- [ ] **Reveal in file manager** opens the correct folder
- [ ] Completion shows in-app notification banner
- [ ] Release assets include platform archive, `SHA256SUMS.txt`, cosign files

## Release page

- [ ] macOS `.dmg`, Windows `.zip`, Linux `.tar.gz` attached
- [ ] `SHA256SUMS.txt` lists all archives
- [ ] macOS SBOM present (`torrin-macos.spdx.json`)

Do not commit copyrighted `.torrent` files to the repository.
