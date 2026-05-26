# Launch kit (v0.3.0)

Use after [README](../../README.md) screenshots and [Release notes](./RELEASE_v0.3.0.md) are live.

**Positioning (reuse everywhere):**

> **Torrin** — open-source BitTorrent client for **macOS**, built with **Qt 6 Quick** and **libtorrent 2.x**: fast-resume, modern list UX, no ads, no bundled telemetry.

**Links:**

- Releases: https://github.com/dineshkn-dev/torrin/releases/latest
- Repo: https://github.com/dineshkn-dev/torrin
- Site (after Pages deploy): https://dineshkn-dev.github.io/torrin/

---

## Screen recording (30–60s)

Suggested flow:

1. Open Torrin (dark mode).
2. Drag a legal test torrent or magnet (e.g. Ubuntu ISO).
3. Show search + sort + ETA in the list.
4. Pause/resume with Space; open detail pane.
5. Toggle light mode via Settings.

Export as MP4; attach to Show HN or Reddit if the platform allows.

---

## Show HN

**Title:**

```
Torrin – open-source BitTorrent client for macOS (Qt6 + libtorrent)
```

**Body:**

```
Torrin is a native macOS torrent client I've been building: Qt 6 Quick UI on
libtorrent 2.x, C++20 core with no Qt in the engine layer.

v0.3 adds list search/sort, ETA, pause/resume all, Reveal in Finder, copy
magnet, keyboard shortcuts, and a resizable master–detail layout. Releases are
signed .dmg files with SHA-256, SBOM, and cosign signatures.

macOS only for now; Windows/Linux are on the roadmap. GPL-3.0, no telemetry.

Download: https://github.com/dineshkn-dev/torrin/releases/latest
Source: https://github.com/dineshkn-dev/torrin

I'd love feedback on UX and what would make you switch from Transmission or
qBittorrent on a Mac.
```

Post at https://news.ycombinator.com/submit — best on a weekday morning US time.

---

## r/macapps

**Title:** `[App] Torrin – open-source torrent client for macOS (Qt6, no telemetry)`

**Body:** Adapt the Show HN body; add screenshot link to README assets. Read sub rules before posting.

## r/MacOS

Only if rules allow; prefer framing as “looking for UX feedback on a native OSS client” rather than a download ad.

---

## Mastodon / X

Short post + 30s clip or static screenshot:

```
Shipped Torrin 0.3 — open-source BitTorrent client for macOS (Qt6 + libtorrent).
Search, sort, ETA, shortcuts, signed .dmg. No telemetry. GPL.
https://github.com/dineshkn-dev/torrin/releases/latest
```

---

## 48-hour response window

After posting:

1. Pin or monitor the [launch feedback issue](https://github.com/dineshkn-dev/torrin/issues/3) (or create from [launch_feedback.yml](../../.github/ISSUE_TEMPLATE/launch_feedback.yml)).
2. Reply to every comment/issue within 48–72h.
3. Label bugs `bug`, good first issues `good first issue` when appropriate.
4. Note referrer in issue title if useful: `[HN] …`, `[reddit] …`.

---

## Do not

- Spam r/torrents with download links.
- Astroturf or buy stars.
- Claim Windows/Linux support before [FUTURE.md](../planning/FUTURE.md#cross-platform) ships.
