# Ghostty Terminal Emulator

> **Plain English:** [The Terminal Window](../plain-english/04-ghostty.md)

## Purpose

Configures the Ghostty GPU-accelerated terminal emulator for fully opaque rendering,
JetBrains Mono typography with Symbols Nerd Font fallback, the Pale Knight OKLCH colour
palette (theme `pale-knight`), sRGB colour management, and comfortable session ergonomics
(asymmetric padding, bar cursor, 100 MB scrollback).

## Inventory

| Path | Role |
| --- | --- |
| `ghostty/config` | 69-line Ghostty configuration. Symlinked to `~/.config/ghostty/config`. |
| `ghostty/themes/pale-knight` | 75-line theme file, placed in the `themes/` subdirectory next to `config`. Ghostty discovers it via `theme = pale-knight`. |

**Sections in `ghostty/config`:**

| Section | Lines | Content |
| --- | --- | --- |
| Theme | 12 | `theme = pale-knight` |
| Fully opaque | 19–27 | Background opacity, titlebar style, unfocused-split settings |
| Type | 31–42 | Font families, size, ligature disable, cell height |
| Window | 46–54 | Window theme, padding, colorspace |
| Cursor | 58–60 | Bar cursor, no blink, hide on typing |
| Terminal | 64–68 | Scrollback 100 MB, copy-on-select, no close confirmation |

**Sections in `ghostty/themes/pale-knight`:**

| Section | Lines | Content |
| --- | --- | --- |
| OKLCH rationale | 1–33 | Comment block: surface derivation, accent weighting, hue table |
| Surface | 38–39 | `background = #0f111a`, `foreground = #a6accd` |
| Cursor | 43–44 | `cursor-color = #5cb1d2` (soul-cyan), `cursor-text = #0f111a` |
| Selection | 46–47 | `selection-background = #444364` (shade), `selection-foreground = #d4d7f1` (pale) |
| Search | 51–52 | `search-background = #c39e5c` (infection), `search-foreground = #0f111a` |
| Split divider | 54 | `split-divider-color = #444364` |
| ANSI 0–7 | 57–64 | Normal colours |
| ANSI 8–15 | 67–75 | Bright colours |

## Public surface

**Reload:** `Cmd+Shift+,` (Ghostty's built-in `reload_config` binding) — takes effect in all
open windows.

**Validation:**
```sh
ghostty +validate-config          # check config syntax
ghostty +list-themes              # confirm pale-knight is visible
```

**Theme discovery:** Ghostty reads custom themes from the `themes/` subdirectory of its
config directory. `theme = pale-knight` resolves to
`~/.config/ghostty/themes/pale-knight`. The `themes/` symlink in `ghostty/` ensures this
works when the whole `ghostty/` dir is linked into `~/.config/ghostty/`.

## Flow

```
Ghostty launch
  → reads ~/.config/ghostty/config
  → resolves `theme = pale-knight` from ~/.config/ghostty/themes/pale-knight
  → font stack: JetBrains Mono (primary) + Symbols Nerd Font Mono (fallback for glyphs)
  → `window-colorspace = srgb` — palette values are rendered as-is, no P3 conversion
  → rendering pipeline: fully opaque (background-opacity = 1, macos-titlebar-style = tabs)
```

**Key parser constraint:** Ghostty has no trailing-comment support. `key = value  # note`
makes the `# note` part of the value and the line fails to parse. All comments sit on their
own line.

## Contracts and invariants

- **Fully opaque.** `background-opacity = 1`, `background-blur = false`, `background-image =`
  (empty clears any inherited value), `macos-titlebar-style = tabs` (prevents the transparent
  macOS titlebar from leaking the desktop). `unfocused-split-opacity = 1` keeps inactive
  splits at full strength.
- **Equal-weight OKLCH accents.** ANSI 1–6 are generated at `L = 0.72` (contrast 5.6–6.0:1
  against `#0f111a`). ANSI 9–14 at `L = 0.80` (contrast 7.5–8.0:1). Equal lightness means
  equal perceptual weight — no colour grabs the eye before the others.
- **sRGB colorspace.** `window-colorspace = srgb` prevents macOS from converting the
  carefully calibrated hex values through the display's colour profile.
- **No trailing comments.** Every comment in `ghostty/config` and `ghostty/themes/pale-knight`
  occupies its own line. This is a hard parser requirement.
- **Ligatures disabled.** `font-feature = -calt` keeps `->`, `!=`, and `=>` as distinct
  characters, not merged ligatures.

## Configuration

| Key | Value | Purpose |
| --- | --- | --- |
| `theme` | `pale-knight` | Loads colour theme from `themes/pale-knight` |
| `background-opacity` | `1` | No transparency |
| `background-blur` | `false` | No background blur |
| `background-image` | (empty) | Clears any inherited image |
| `macos-titlebar-style` | `tabs` | Solid titlebar, not transparent macOS default |
| `unfocused-split-opacity` | `1` | Inactive splits stay at full strength |
| `unfocused-split-fill` | `#0f111a` | Fill colour for unfocused splits |
| `font-family` | `JetBrains Mono` (first), `Symbols Nerd Font Mono` (second) | Font stack |
| `font-size` | `13` | |
| `font-feature` | `-calt` | Disables contextual alternates (ligatures) |
| `adjust-cell-height` | `12%` | Extra line spacing; box-drawing still joins |
| `font-thicken` | `false` | No synthetic thickening |
| `window-theme` | `ghostty` | Chrome follows Ghostty theme, not macOS appearance |
| `window-padding-x` | `10` | Horizontal inner padding |
| `window-padding-y` | `10,5` | 10 px top, 5 px bottom (tmux bar occupies last row) |
| `window-padding-balance` | `true` | |
| `window-colorspace` | `srgb` | Render palette values without P3 conversion |
| `cursor-style` | `bar` | Thin vertical bar, not block |
| `cursor-style-blink` | `false` | Static cursor |
| `mouse-hide-while-typing` | `true` | |
| `scrollback-limit` | `100000000` | 100 MB; tmux keeps its own 50 k-line history |
| `copy-on-select` | `clipboard` | Selection goes to system clipboard |
| `confirm-close-surface` | `false` | Close without dialog (tmux owns the session) |

## Boundaries and dependencies

| Dependency | Required for |
| --- | --- |
| macOS | Ghostty is macOS-native; `macos-titlebar-style` and `window-colorspace` are macOS keys |
| JetBrains Mono | Primary monospace font; no fallback configured if absent |
| Symbols Nerd Font Mono | Glyph fallback for prompt symbols and eza icons |
| Ghostty ≥ 1.0 | `unfocused-split-fill`, `window-colorspace`, `window-padding-balance` |

## Tests

No automated tests. Manual verification:

```sh
ghostty +validate-config                          # confirms config parses
ghostty +list-themes | grep pale-knight           # confirms theme is discovered
```

Colour accuracy and rendering are verified visually. The OKLCH rationale in the theme file
documents the expected contrast ratios (5.6–6.0:1 for ANSI 1–6, 7.5–8.0:1 for 9–14).

## Debt and traps

- **No trailing comments** — the most common mistake when editing the config. Adding
  `key = value  # comment` silently assigns the comment text as part of the value;
  the line fails to parse and the setting is ignored.
- **Font dependency.** If JetBrains Mono or Symbols Nerd Font Mono is not installed, Ghostty
  falls back to system fonts silently. The prompt and eza icons that rely on Nerd Font glyphs
  will render as missing boxes or replacement characters.
- **`themes/` must be in the config directory.** The symlink in `ghostty/themes` points the
  entire `themes/` directory; if only `ghostty/config` is linked and not the directory,
  `pale-knight` will not be found.
- **`unfocused-split-fill` must match `background`.** Currently both are `#0f111a`. If the
  background colour is changed in the theme file without updating `unfocused-split-fill` in
  `config`, inactive splits will have a visible seam.

## Change guide

- **Changing a colour:** edit `ghostty/themes/pale-knight`. Reload with `Cmd+Shift+,`.
  Check that the matching colour in `tmux/tmux.conf` and the `PK` array in `zsh/zshrc`
  is also updated — the three files share the same 11-token palette.
- **Adding a keybinding:** add a `keybind = ...` line to `ghostty/config` on its own line,
  with no trailing comment.
- **Adjusting padding:** change `window-padding-y` (format is `top,bottom`) and/or
  `window-padding-x`. Reload with `Cmd+Shift+,`.
- **Validating before reloading:** `ghostty +validate-config` reports parse errors.
