# Tmux Terminal Multiplexer

> **Plain English:** [The Workspace Grid](../plain-english/03-tmux.md)

## Purpose

Configures tmux as a persistent terminal session manager with the Pale Knight palette,
`C-s` prefix, 1-based window and pane indexing, directory-inheriting splits, hjkl pane
navigation, lazygit and tuicr popups, and a status bar whose session badge shifts from
soul-cyan to infection-amber while the prefix is held.

## Inventory

| Path | Role |
| --- | --- |
| `tmux/tmux.conf` | 166-line configuration. Symlinked to `~/.config/tmux/tmux.conf`. |

**Sections inside `tmux.conf`:**

| Section | Lines | Content |
| --- | --- | --- |
| Palette | 32–42 | `%hidden` variable declarations for 11 colour tokens |
| Prefix | 46–48 | Prefix changed to `C-s`; `C-s C-s` passes a literal `C-s` |
| Numbering | 52–56 | `base-index 1`, `pane-base-index 1`, `renumber-windows on` |
| Windows and panes | 60–94 | Rename, kill, split, zoom, hjkl, lazygit, tuicr, reload |
| Behaviour | 98–110 | Mouse, escape-time, focus-events, history, clipboard, vi keys, true colour |
| Chrome | 113–133 | Pane borders, messages, copy-mode, popup style |
| Status bar | 137–166 | Session badge, right segment, window format strings |

## Public surface

### Prefix: `C-s`

| Key sequence | Action |
| --- | --- |
| `prefix \` or `prefix \|` | Split current pane left/right, new pane 25% wide (inherits directory) |
| `prefix -` | Split current pane top/bottom (inherits directory) |
| `prefix r` | Rename current window (empty prompt) |
| `prefix S` | Rename current session (empty prompt) |
| `prefix x` | Kill current pane (no confirmation) |
| `prefix X` | Kill current window (no confirmation) |
| `prefix c` | New window at the session's root directory |
| `prefix m` | Zoom current pane (toggle; overrides default `mark-pane`) |
| `prefix h` / `j` / `k` / `l` | Select pane left / down / up / right (overrides `last-window` for `l`) |
| `prefix g` | lazygit popup, 90 % × 90 %, current pane's repository |
| `prefix t` | tuicr popup, 90 % × 90 %, current pane's directory (overrides `clock-mode`) |
| `prefix C-s` | Send literal `C-s` to the pane |
| `prefix C-r` | Reload `~/.config/tmux/tmux.conf` in place |

### Status bar

- **Left** — session badge: `◈ <session>`. Soul-cyan at rest; shifts to infection-amber
  background while prefix is held (`#{?client_prefix,...}`).
- **Right** — current pane's directory basename (essence/violet), clock in HH:MM (lifeblood),
  hostname (bone).
- Active window: bold pale text, soul-cyan diamond `◆`, zoom indicator `⊡` when pane is
  zoomed (`#{?window_zoomed_flag, ⊡,}`).
- Bell/activity: infection-amber / essence-violet.

## Flow

```
tmux server start → reads ~/.config/tmux/tmux.conf
  → palette %hidden variables resolved at parse time (not runtime)
  → key table populated (root and prefix tables)
  → status bar format strings registered; status-interval 5s timer starts
        ↓
User presses C-s (prefix)
  → tmux enters prefix key table
  → Next key dispatched:
      \  →  split-window -h -l 25% -c #{pane_current_path}
      g  →  display-popup -E -d #{pane_current_path} -w 90% -h 90% "lazygit"
      C-r →  source-file ~/.config/tmux/tmux.conf; display-message
```

The lazygit and tuicr popups use `display-popup -E` (close on exit) with `-d` set to the
current pane's working directory, so the popup inherits the right repository context.

## Contracts and invariants

- **1-based indexing.** `base-index 1` and `pane-base-index 1` are both set.
  `renumber-windows on` closes gaps. `prefix 1` always reaches the first window.
- **Splits inherit directory.** All `split-window` bindings use `-c "#{pane_current_path}"`.
  New windows (`prefix c`) start at `#{session_path}`, the directory the session was
  created in, so a project session keeps its root no matter where a pane wandered.
- **`prefix C-s` round-trips.** `bind C-s send-prefix` ensures applications that need a
  literal `C-s` (flow control, terminal XOFF) can receive it.
- **Palette variables are `%hidden`.** They are resolved at config parse time and do not
  appear in `tmux show-options` output, keeping the option namespace clean.
- **True colour requires terminal cooperation.** `terminal-features` declares RGB for
  `xterm-256color`, `xterm-ghostty`, and `alacritty`. Without a matching terminal, the
  palette degrades to 256-colour approximations.
- **`fill=` in message styles (tmux ≥ 3.6).** The `fill=$CRYPT` on `message-style` is
  required to erase the old status line behind the prompt overlay. Without it window names
  bleed through.

## Configuration

| Setting | Value | Effect |
| --- | --- | --- |
| `prefix` | `C-s` | Replaces default `C-b` |
| `base-index` | `1` | First window is `1`, not `0` |
| `pane-base-index` | `1` | First pane is `1`, not `0` |
| `renumber-windows` | `on` | Gaps closed after window close |
| `history-limit` | `50000` | Scrollback per pane |
| `escape-time` | `10` ms | Distinguishes Esc from Meta prefix |
| `focus-events` | `on` | Editors receive `FocusIn`/`FocusOut` |
| `mouse` | `on` | Click panes/windows, drag borders, wheel scroll |
| `mode-keys` | `vi` | Copy mode uses vi motions |
| `default-terminal` | `tmux-256color` | Base terminal type |
| `status-interval` | `5` s | Status bar refresh rate |
| `popup-border-lines` | `rounded` | Popup frame style |
| `pane-border-lines` | `heavy` | Pane separator weight |
| Symlink target | `~/.config/tmux/tmux.conf` | |

## Boundaries and dependencies

| Dependency | Required for |
| --- | --- |
| tmux ≥ 3.2 | `display-popup` (the popup feature) |
| tmux ≥ 3.6 | `fill=` in `message-style` |
| `lazygit` on `PATH` | `prefix g` popup; fails silently with an error in the popup if absent |
| `tuicr` on `PATH` | `prefix t` popup; same failure mode |
| Terminal emulator with RGB support | True colour palette; must advertise one of the `terminal-features` entries |

## Tests

No automated test suite. Config syntax can be validated with:

```sh
tmux -f /dev/null -L tmux-test new-session -d \; source-file tmux/tmux.conf \; kill-server
```

Visual verification is required for colour accuracy and popup functionality.

## Debt and traps

- **`fill=` dependency on tmux 3.6+.** If an older tmux is used, window names bleed through
  behind command prompts. No version guard is in the config.
- **`l` overrides `last-window`.** `bind l select-pane -R` is a deliberate trade-off:
  pane navigation wins over the default `last-window` binding. There is no alternative
  binding for `last-window`.
- **`m` overrides `mark-pane`.** `bind m resize-pane -Z` shadows the default `mark-pane`
  binding. Mark-pane functionality is unavailable without rebinding.
- **`lazygit` and `tuicr` are not guarded.** If either is absent from `PATH`, `prefix g`/`t`
  opens a popup that immediately exits with an error message. No fallback or guard exists.
- **`new-window` follows the session root, not the pane.** `bind c new-window -c
  "#{session_path}"` is resolved by tmux at invocation. A session started without `-c`
  inherits the shell's directory at creation time, which may be `$HOME`.

## Change guide

- **Adding a key binding:** append a `bind` line to the `Windows and panes` section. Check
  that the key does not shadow a used default; consult `tmux list-keys`.
- **Changing status bar colours:** edit the relevant `%hidden` variable and the format
  strings that reference it. Reload with `prefix C-r`.
- **Adjusting popup size:** change the `-w` and `-h` percentages on the `display-popup` line.
- **Reloading after config change:** `prefix C-r` sources the file in place. No server
  restart is needed unless `default-terminal` or `terminal-features` changes.
