# Torrin conventions

## C++ (`src/core/`, `include/torrin/`)

- **Standard:** C++20 in application code; libtorrent may impose C++14+.
- **Naming:** `PascalCase` types, `snake_case` functions and files, `kConstant` or `constexpr` for constants.
- **Headers:** Public API under `include/torrin/`; implementation in `src/core/`.
- **Errors:** Use `std::expected` or explicit `Result<T>` typedef; no exceptions across the engine thread boundary.
- **Logging:** `spdlog` in core (when added); include `session_id` / `info_hash` where relevant.

## Qt / QML

- **Models** live in `src/models/`; expose only value types and enums to QML.
- **QML** under `src/ui/qml/`; theme tokens in `theme/Theme.qml`.
- **No business logic in QML** — only presentation and user input; delegate to `AppController`.

## Git

- **Conventional Commits:** `feat:`, `fix:`, `docs:`, `ci:`, `refactor:`, `test:`, `chore:`.
- **PRs:** must pass `scripts/verify.sh` locally or CI equivalent.

## Security

- Validate magnet URIs and `.torrent` size before parse.
- Sanitize display names; reject path segments containing `..`.
