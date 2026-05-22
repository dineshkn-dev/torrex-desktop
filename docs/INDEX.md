# Torrex documentation index

Read [AGENTS.md](../AGENTS.md) first.

| Document | Purpose | Status |
|----------|---------|--------|
| [CONVENTIONS.md](CONVENTIONS.md) | Naming, errors, logging, QML/C++ rules | Active |
| [specs/MVP.md](specs/MVP.md) | v0.1 scope and acceptance criteria | Active |
| [tracker/ROADMAP.yaml](tracker/ROADMAP.yaml) | Machine-readable progress | Active |
| [architecture/ADR-001-stack.md](architecture/ADR-001-stack.md) | C++ / libtorrent / Qt6 | Accepted |
| [architecture/ADR-002-threading.md](architecture/ADR-002-threading.md) | Engine thread model | Accepted |
| [architecture/ADR-003-security.md](architecture/ADR-003-security.md) | Security baseline | Accepted |
| [architecture/ADR-004-documentation.md](architecture/ADR-004-documentation.md) | Doc + tracker system | Accepted |
| [architecture/ADR-005-macos-first-ci.md](architecture/ADR-005-macos-first-ci.md) | macOS-first CI scope | Accepted |
| [security/THREAT_MODEL.md](security/THREAT_MODEL.md) | Threat model | Draft |
| [automation/CURSOR.md](automation/CURSOR.md) | Cursor automation recipes | Draft |
| [runbooks/release.md](runbooks/release.md) | Release process | Draft |

## Validation

```bash
./scripts/validate-docs.sh
```

Runs in CI on every pull request.
