# Contributing

Torrin ships on **macOS**, **Windows**, and **Linux**. See [AGENTS.md](AGENTS.md) for build commands and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for how the code is structured.

```bash
./scripts/bootstrap.sh
./scripts/verify.sh
```

Before a PR: run `verify.sh`, use conventional commits (`feat:`, `fix:`, `docs:`, …), and update `CHANGELOG.md` for user-visible changes.

Issues: [bug](https://github.com/dineshkn-dev/torrin/issues/new?template=bug_report.yml) · [feature](https://github.com/dineshkn-dev/torrin/issues/new?template=feature_request.yml). Security: [SECURITY.md](SECURITY.md).

To refresh README screenshots: `./scripts/prepare-and-capture-screenshots.sh` (see [docs/assets/README.md](docs/assets/README.md)).
