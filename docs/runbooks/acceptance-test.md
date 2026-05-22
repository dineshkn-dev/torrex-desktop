# v0.1 acceptance test (manual)

Run on a clean macOS build after tagging a release candidate.

## Build under test

```bash
./scripts/bootstrap.sh
cmake --preset dev
cmake --build --preset dev
open build/dev/bin/Torrex.app
```

Or install from the GitHub Release `.dmg` for the tagged version.

## Checklist

### Add and download

- [ ] Add a **legal** torrent via magnet (e.g. Ubuntu Desktop `.iso` from the official site’s magnet link).
- [ ] Add the same or another legal torrent via **File → Add .torrent** (official `.torrent` file).
- [ ] Confirm progress, rates, and state update in the list and **Overview** tab.
- [ ] **Drag-and-drop** a `.torrent` file onto the window; download starts.

### Torrent control

- [ ] **Pause** and **Resume** the active torrent.
- [ ] **Files** tab: change a file to **Skip** and confirm behavior (skipped file not downloaded).
- [ ] Enable **Sequential download**; verify order preference (first pieces prioritized).
- [ ] **Remove** torrent (keep files), then remove with delete data from context menu.

### Settings and network

- [ ] Open **Settings**; change default download folder and bandwidth limits; **OK** applies.
- [ ] Configure **proxy** only if you have a test SOCKS5/HTTP proxy; otherwise leave disabled.
- [ ] Change listen port / UPnP toggles; restart app and confirm settings persist.

### Persistence and notifications

- [ ] With at least one torrent active, **quit** Torrex and reopen.
- [ ] Torrent list and progress **restore** from fast-resume data.
- [ ] When a download completes, an in-app **notification banner** appears.

### Release artifacts (maintainers)

- [ ] Tag `v*` triggers **Release** workflow.
- [ ] GitHub Release includes `.dmg`, `SHA256SUMS.txt`, SPDX SBOM, and cosign `.sig` / `.crt` files.

## Notes

- Do not commit copyrighted `.torrent` files or proprietary magnets to the repository.
- Notarization is optional for v0.1; document Gatekeeper warnings if distributing unsigned builds.
