# README and release assets

| File | Purpose |
|------|---------|
| `torrin-dark.png` | Dark / AMOLED UI preview for README and releases |
| `torrin-light.png` | Light appearance preview |

## Regenerate

Grant **Screen Recording** to Terminal (or Cursor), then:

```bash
./scripts/prepare-and-capture-screenshots.sh
```

Or, if already built with `TORRIN_SCREENSHOT=1` running:

```bash
export TORRIN_SCREENSHOT=1
./scripts/capture-screenshots.sh
```

`TORRIN_SCREENSHOT` uses `/Users/Shared/Torrin/Downloads`, a temp session DB, demo Linux ISO magnets, and **synthetic transfer stats** for README captures (no personal paths or media titles).

The script launches Torrin, **maximizes the window** to the visible display, and captures via `screencapture -l` (see `scripts/capture-window.swift`).

**Fallback** if Screen Recording is denied:

```bash
python3 scripts/render-readme-preview.py
```

Commit updated PNGs after regenerating.
