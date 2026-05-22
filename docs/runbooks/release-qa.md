# Release QA checklist

Use before or after publishing a **tagged** release build.

## Build under test

- GitHub Release `.dmg` for the tag, or local:

```bash
cmake --preset ci-release
cmake --build --preset ci-release
./scripts/package-macos.sh build/ci-release
```

## Checklist

- [ ] Add a **legal** torrent via magnet and via `.torrent`
- [ ] Pause, resume, remove (with and without delete data)
- [ ] Files tab: change priority; toggle sequential download
- [ ] Settings persist after restart (folder, limits, proxy if used)
- [ ] Quit and reopen: torrents restore from fast-resume
- [ ] Drag-and-drop adds a torrent
- [ ] Completion shows in-app notification banner
- [ ] Release assets include `.dmg`, `SHA256SUMS.txt`, SBOM, cosign files

Do not commit copyrighted `.torrent` files to the repository.
