# Engine session specification

## Scope

`torrex_core::SessionManager` owns the libtorrent session lifecycle.

## Acceptance criteria

1. `start()` creates a session on a dedicated worker thread; idempotent.
2. `shutdown()` drains alerts, saves resume data, joins thread.
3. `snapshots()` returns immutable `TorrentSnapshot` vector for UI (throttled externally).
4. No Qt types in `src/core/` or `include/torrex/`.

## Tests

- `tests/core/session_manager_test.cpp` — start/shutdown without leak (smoke)
- Future: add magnet integration test with private tracker disabled fixture
