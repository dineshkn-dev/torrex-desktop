# Engine session specification

## Scope

`torrex_core::SessionManager` owns the libtorrent session lifecycle.

## Acceptance criteria

1. `start()` creates a session on a dedicated worker thread; idempotent.
2. `shutdown()` joins worker thread.
3. `snapshots()` returns `TorrentSnapshot` vector updated from libtorrent alerts.
4. `add_magnet()` / `add_torrent_file()` enqueue adds with validation; saves to configurable path.
5. `pause_torrent()` / `resume_torrent()` / `remove_torrent()` enqueue by info-hash key; optional delete data on remove.
6. No Qt types in `src/core/` or `include/torrex/`.

## Tests

- `tests/core/session_manager_test.cpp` — start/shutdown without leak (smoke)
- Future: add magnet integration test with private tracker disabled fixture
