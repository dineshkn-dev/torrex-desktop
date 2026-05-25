# Engine session specification

`torrin_core::SessionManager` owns the libtorrent session lifecycle.

## Behavior

1. `start()` runs the session on a dedicated worker thread (idempotent).
2. `shutdown()` persists fast-resume state and joins the worker.
3. `snapshots()` returns current `TorrentSnapshot` values from libtorrent alerts.
4. `add_magnet()` / `add_torrent_file()` validate input and enqueue adds.
5. `pause_torrent()` / `resume_torrent()` / `remove_torrent()` operate by info-hash key.
6. `set_file_priority()` / `set_sequential_download()` enqueue per-torrent changes.
7. `set_session_settings()` applies bandwidth, port, DHT/UPnP, and proxy options.
8. No Qt types in `src/core/` or `include/torrin/`.

## Tests

`tests/core/session_manager_test.cpp`, `add_torrent_test.cpp`, `torrent_ops_test.cpp`, `session_settings_test.cpp`, `torrent_controls_test.cpp`.
