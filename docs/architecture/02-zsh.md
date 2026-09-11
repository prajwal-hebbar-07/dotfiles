# Zsh Shell Environment

> **Plain English:** [The Command Deck](../plain-english/02-zsh.md)

## Purpose

Configures the interactive zsh shell: environment variables, globbing, history,
completion caching, fzf/fzf-tab picker integration, Pale Knight palette on file colours,
two-line git-aware prompt, Homebrew plugin loading, tool aliases, and a lazy-load nvm
shim — all in a deliberate order required for correct widget stacking.

## Inventory

| Path | Role |
| --- | --- |
| `zsh/zshrc` | 628-line interactive shell configuration. Symlinked to `~/.zshrc`. |
| `zsh/bin/pk-preview` | 56-line POSIX sh script: the fzf preview pane. Dispatches tree, bat, hexdump, or a plain echo depending on the target type. Symlinked to `~/.local/bin/pk-preview`. |

## Public surface

### Aliases

| Alias | Expands to |
| --- | --- |
| `ls` | `eza` with icons, directories first, auto colour (falls back to plain `ls -G`) |
| `l` | Long listing, git status, relative timestamps |
| `ll` | Long listing, git status, ISO timestamps |
| `la` | Long, all files (dotfiles), git status, ISO timestamps |
| `lt` / `lta` | Tree (2 levels) / tree (3 levels, including hidden) |
| `lS` / `lm` | Sorted by size / by modification time, largest/newest first |
| `cat` | `bat --paging=never` (falls back silently when bat absent) |
| `catp` | `bat --plain --paging=never` (no line numbers, no header) |
| `z` | `zoxide` jump (smartest recent directory) |
| `ff` | `fzf` file picker → opens in `$EDITOR` |
| `mkcd` | `mkdir -p` then `cd` |
| `up [n]` | Climb `n` directory levels (default 1) |
| `reload` | `exec zsh` (restart the shell in place) |
| `g` / `gs` / `gd` / `gl` / `ga` / `gc` / `gp` | Common git shortcuts |
| `lg` | `lazygit` |
| `t` / `ta` / `tl` | tmux / tmux attach / tmux list-sessions |
| `ports` | `lsof -nP -iTCP -sTCP:LISTEN` |
| `path` | Print `$path` array, one entry per line |
| `zshrc` | Open `~/.zshrc` in `$EDITOR` |
| `rg` | `rg --smart-case --hidden --glob=!.git` |
| `fd` | `fd --hidden --follow --exclude=.git` |

### Functions

| Function | Behaviour |
| --- | --- |
| `nvm()` | Lazy shim: loads `~/.nvm/nvm.sh` on first call, replaces itself, forwards args |
| `mkcd()` | `mkdir -p "$1" && cd "$1"` |
| `up()` | Climbs `n` parent directories |
| `ff()` | `fzf` file picker, opens result in `$EDITOR` |
| `+vi-pk-dirty()` | vcs_info hook: one `git status --porcelain=v1` yields staged/unstaged/untracked/conflict counts |
| `+vi-pk-divergence()` | vcs_info hook: ahead/behind counts via `rev-list --count` |

### Environment variables exported

`EDITOR`, `VISUAL`, `PAGER`, `LESS`, `LANG`, `HOMEBREW_NO_ENV_HINTS`, `LS_COLORS`,
`EZA_COLORS`, `BAT_THEME` (`ansi`), `BAT_STYLE`, `MANPAGER`, `MANROFFOPT`,
`FZF_DEFAULT_OPTS`, `FZF_DEFAULT_COMMAND`, `FZF_CTRL_T_COMMAND`, `FZF_ALT_C_COMMAND`,
`FZF_CTRL_T_OPTS`, `FZF_ALT_C_OPTS`, `FZF_CTRL_R_OPTS`, `NVM_DIR`

### Key bindings

| Key | Action |
| --- | --- |
| `→` | Accept autosuggestion one char |
| `C-e` / `M-→` | Accept full autosuggestion |
| `C-space` / `C-@` / `M-Enter` | Accept autosuggestion and execute |
| `↑` / `↓` / `C-p` / `C-n` | History substring search up/down |
| `Tab` | fzf-tab picker (or zsh arrow-key menu as fallback) |
| `/` (in picker) | Accept a directory candidate and continue descending |
| `<` / `>` (in picker) | Switch between match groups |
| `C-/` (in picker) | Toggle preview pane |
| `C-r` | fzf history search; `C-y` copies without running |
| `C-t` | Insert a file path (with pk-preview) |
| `M-c` | Jump to a directory below here (with pk-preview) |
| `C-x C-e` | Open the current command line in `$EDITOR` |
| `C-→` / `C-←` | Forward / backward by word |
| `C-u` | Kill left of cursor (not the whole line) |
| `Shift-Tab` | Walk completion menu backwards |

## Flow

Shell startup is strictly ordered. Any reshuffle breaks widget stacking:

```
env (Homebrew shellenv, PATH dedup, EDITOR, PAGER, LANG)
  → options (globbing, auto_cd, history behaviour)
  → history (HISTFILE 200k, extended_history, share_history)
  → completion (compinit cache under ~/.cache/zsh/zcompdump-$ZSH_VERSION,
                refreshed at most once per 24h)
  → file colours (LS_COLORS via $_pk_lscolors array, EZA_COLORS)
  → fzf (FZF_DEFAULT_OPTS, key bindings, fd commands)
  → fzf-tab (must load after compinit and fzf; replaces zsh menu with fzf picker)
  → autosuggestions (ZSH_AUTOSUGGEST_STRATEGY=history,completion)
  → syntax highlighting (must come after every widget it wraps)
  → history-substring-search (must come after syntax highlighting)
  → keys (emacs keymap, then plugin-specific bindings)
  → prompt (vcs_info, timer hooks, 2-line PROMPT + RPROMPT)
  → tools (eza, bat, zoxide, rg, fd, nvm shim, aliases)
  → local (~/.zshrc.local sourced last)
```

`compinit` is guarded: if the dump file is less than 24 hours old, `-C` skips the full
scan (`compinit -C`). Otherwise a full scan regenerates the dump.

## Contracts and invariants

- **Load order is the contract.** `zsh-syntax-highlighting` must load after every widget it
  wraps. `zsh-history-substring-search` must load after `zsh-syntax-highlighting`. Violating
  this produces silent misbehaviour.
- **PATH is deduplicated.** `typeset -U path PATH` ensures no duplicates, even after Homebrew,
  nvm, and local overrides all append to it.
- **Startup time target ≈ 80 ms.** Achieved by: `compinit -C` on cached dumps, nvm lazy-load,
  guarded Homebrew `shellenv`.
- **`zshrc` is a symlink target.** Anything an installer appends goes into the repo file.
  Machine-specific content belongs in `~/.zshrc.local`.
- **All Homebrew plugin blocks are guarded.** `[[ -r /path ]]` before sourcing; missing plugins
  are silently skipped, so the shell still works on a fresh machine.
- **`pk-preview` lives on PATH as a script, not a shell function**, because fzf runs previews
  in a fresh `$SHELL -c` that never sources `~/.zshrc`.

## Configuration

| Config or variable | Value / location |
| --- | --- |
| Completion dump cache | `~/.cache/zsh/zcompdump-$ZSH_VERSION` |
| Completion cache | `~/.cache/zsh/compcache` |
| History file | `~/.zsh_history`, 200 000 entries |
| Local overrides | `~/.zshrc.local` (sourced last, not tracked) |
| `BAT_THEME` | `ansi` — inherits terminal's 16-colour palette, never drifts from Pale Knight |
| `NVM_DIR` | `~/.nvm` |
| `EDITOR` | `cursor --wait` |
| `FZF_PREVIEW_LINES` | Read by `pk-preview` from environment; defaults to 200 |
| `ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE` | 80 — no guessing on long pastes |

## Boundaries and dependencies

**Homebrew packages** (shell plugin source paths are hardcoded to `/opt/homebrew/share/`):

| Package | Purpose |
| --- | --- |
| `zsh-syntax-highlighting` | Per-character colour as you type |
| `zsh-autosuggestions` | Greyed-in history/completion suggestion |
| `zsh-completions` | Extra completion definitions on `fpath` |
| `zsh-history-substring-search` | `↑` walks only matching history |
| `fzf-tab` | Replaces zsh completion menu with fzf picker |
| `eza` | `ls` replacement with icons and git status |
| `bat` | `cat` replacement with syntax highlighting |
| `fzf` | Fuzzy finder; also provides `C-r`, `C-t`, `M-c` bindings |
| `fd` | Fast `find`; powers `FZF_DEFAULT_COMMAND` |
| `ripgrep` (`rg`) | Fast grep with `--smart-case` default |
| `zoxide` | Directory jumper; `z` alias |
| `lazygit` | TUI git client; `lg` alias |
| `font-symbols-only-nerd-font` | Icons in eza and prompt |

**nvm** — `~/.nvm/nvm.sh`; installed separately, not via Homebrew.

## Tests

No automated regression suite. Syntax can be checked with:

```sh
zsh -n zsh/zshrc
```

Startup time benchmarking:
```sh
for i in $(seq 5); do time zsh -ic exit; done
```

There are no unit tests for the prompt hook functions (`+vi-pk-dirty`,
`+vi-pk-divergence`) or the fzf preview dispatching logic in `pk-preview`.

## Debt and traps

- **Hardcoded `/opt/homebrew/` paths.** All plugin `source` lines assume Apple Silicon
  Homebrew at `/opt/homebrew`. Intel Macs use `/usr/local`; the config breaks there without
  edits.
- **`compinit` insecure-directory trap.** Homebrew leaves `share/` group-writable.
  `compinit` refuses to load completions from it. Fix: `chmod go-w "$(brew --prefix)/share"`.
  Not guarded — if the `chmod` is not run, completions silently fail.
- **nvm default alias does not resolve.** The lazy-load comment in `zshrc` notes that
  `nvm use default` currently resolves to nothing (`default → node → stable`, no local match).
  The startup PATH hack (`_pk_node=("$NVM_DIR"/versions/node/*/bin(Nn[-1]))`) picks the
  newest installed version directly. If no version is installed, the nvm block is entirely
  skipped — `node` is not on PATH.
- **`ZSH_AUTOSUGGEST_MANUAL_REBIND=1`** skips the per-prompt autosuggestion widget rebind.
  If a plugin loaded after autosuggestions replaces a widget, suggestions may attach to the
  wrong function. This is a deliberate performance trade-off, not a bug yet.
- **Antigravity CLI installer appends to `~/.zshrc`** (lines 625-627 in the current file).
  Those lines live inside the repo now; they must be reviewed rather than deleted, and they
  expose the `--dangerously-skip-permissions` flag on the `agy` alias.

## Change guide

- **Adding an alias:** place it in the `Aliases and small functions` section, respecting the
  tool grouping.
- **Adding a plugin:** add a guarded `[[ -r /opt/homebrew/share/<plugin>/<plugin>.zsh ]]`
  block in the correct position in the load order. Document the required load order
  constraints in a comment.
- **Changing palette colours:** update the `PK` associative array at the top of `zshrc`, the
  matching entries in `LS_COLORS` / `EZA_COLORS`, and the `FZF_DEFAULT_OPTS` colour block.
  The palette is shared with `tmux/tmux.conf` and `ghostty/themes/pale-knight`.
- **Changing `$EDITOR`:** update both `EDITOR` and `VISUAL` at the top of the environment
  section. The current value `cursor --wait` blocks until the file is closed.
