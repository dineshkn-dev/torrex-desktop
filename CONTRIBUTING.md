# Contributing to Torrin

Thanks for your interest in Torrin. This project is **macOS-first** today; see [docs/planning/FUTURE.md](docs/planning/FUTURE.md) for cross-platform plans.

## Quick start

```bash
./scripts/bootstrap.sh          # once: vcpkg, preset, pre-commit
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
./scripts/run-dev.sh
```

Full contributor workflow: [AGENTS.md](AGENTS.md).

## Before you open a PR

1. Run `./scripts/verify.sh` (format, build, tests).
2. Follow [docs/CONVENTIONS.md](docs/CONVENTIONS.md) for C++ and QML.
3. Update [docs/specs/PRODUCT.md](docs/specs/PRODUCT.md) if user-visible behavior changes.
4. Run `./scripts/validate-docs.sh` when docs or ROADMAP change.

## Reporting issues

Use the [bug report](https://github.com/dineshkn-dev/torrin/issues/new?template=bug_report.yml) or [feature request](https://github.com/dineshkn-dev/torrin/issues/new?template=feature_request.yml) templates.

## Security

See [SECURITY.md](SECURITY.md) for vulnerability reporting — please do not open public issues for security bugs.

## README screenshots

To refresh marketing screenshots after UI changes:

```bash
./scripts/capture-screenshots.sh
```

See [docs/assets/README.md](docs/assets/README.md).
