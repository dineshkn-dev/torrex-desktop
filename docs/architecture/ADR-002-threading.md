# ADR-002: Engine threading model

## Status

Accepted

## Decision

- One **worker thread** owns `libtorrent::session` and calls `pop_alerts()`.
- UI thread sends commands via a **lock-free or mutex-backed queue** of `TorrentCommand` values.
- UI receives **throttled snapshots** (4–10 Hz) as copies of `TorrentSnapshot`.
- Never pass `torrent_handle` or raw libtorrent types to Qt/QML.

## Rationale

libtorrent is not thread-safe for arbitrary cross-thread handle use. Throttling prevents QML property churn.
