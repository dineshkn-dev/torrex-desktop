# Torrin threat model (draft)

## Assets

- User download directory contents
- Torrent list and settings (SQLite + resume files)
- Network reputation (IP exposure to peers and trackers)

## Threats

| ID | Threat | Mitigation |
|----|--------|------------|
| T1 | Malicious `.torrent` (billion laughs, huge files) | Size cap, parse limits, libtorrent validation |
| T2 | Path traversal in torrent names | Sanitize paths; reject `..` |
| T3 | Tracker MITM | HTTPS trackers where available; user warnings |
| T4 | Malicious peers | libtorrent protocol handling; no custom peer parser in v1 |
| T5 | Supply-chain compromise | vcpkg pin, SBOM, signed releases |
| T6 | Secret leakage in repo | gitleaks, pre-commit, no keys in client |

## Out of scope (current release)

- Built-in content search or indexers
- VPN integration

## Reporting

See [SECURITY.md](../../SECURITY.md).
