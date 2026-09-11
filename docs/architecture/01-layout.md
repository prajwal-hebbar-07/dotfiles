# Repository Layout

> **Plain English:** [The Blueprint](../plain-english/01-layout.md)

## Purpose

Defines the single-source-of-truth directory structure for this dotfiles repository and records
the symlink conventions that connect each config file to the location the tool expects on macOS.

## Inventory

| Path | Role |
| --- | --- |
| `README.md` | Central human-readable reference: tool descriptions, keybinding tables, palette rationale, setup commands, and symlink targets. 500 lines. |
| `AGENTS.md` | Machine-facing context injected at the start of every agent session; lists skills and agents available in this repo. |
| `zsh/` | Zsh shell environment: `zshrc` (628-line configuration) and `bin/pk-preview` (fzf preview script). |
| `tmux/` | Tmux multiplexer: `tmux.conf` (166 lines). |
| `ghostty/` | Ghostty terminal emulator: `config` (69 lines) and `themes/pale-knight` (75-line theme file). |
| `ohmypi/` | Oh My Pi coding harness: `RULES.md`, `agents/committer.md`, `mcp.json`, and `skills/` (10 skill packages). |
| `docs/` | Twin documentation, created by this sweep. Not yet present at the start of the bootstrap. |

## Public surface

**Setup symlinks** — all targets on macOS Apple Silicon:

```
~/.zshrc                         → zsh/zshrc
~/.local/bin/pk-preview          → zsh/bin/pk-preview
~/.config/tmux/tmux.conf         → tmux/tmux.conf
~/.config/ghostty/config         → ghostty/config
~/.config/ghostty/themes         → ghostty/themes

# Oh My Pi harness
~/.omp/agent/RULES.md            → ohmypi/RULES.md
~/.omp/agent/mcp.json            → ohmypi/mcp.json
~/.omp/agent/agents/committer.md → ohmypi/agents/committer.md
~/.omp/agent/skills/<name>       → ohmypi/skills/<name>   (10 entries)

# Cursor editor
~/.cursor/skills/<name>          → ohmypi/skills/<name>   (7 entries, excludes commit)

# Gemini / Antigravity CLI
~/.gemini/config/skills/<name>   → ohmypi/skills/<name>   (4 entries: commit, docs-twins,
                                                           docs-verify, repo-docs)
```

**Intended future directories** (recorded in `README.md`, not yet committed):
`brave/`, `cursor/`

## Flow

```
git clone → repo/
    │
    ├── ln -sfn zsh/zshrc          ~/.zshrc
    ├── ln -sfn zsh/bin/pk-preview ~/.local/bin/pk-preview
    ├── ln -sfn tmux/tmux.conf     ~/.config/tmux/tmux.conf
    ├── ln -sfn ghostty/config     ~/.config/ghostty/config
    ├── ln -sfn ghostty/themes     ~/.config/ghostty/themes
    ├── ln -sfn ohmypi/RULES.md    ~/.omp/agent/RULES.md
    ├── ln -sfn ohmypi/mcp.json    ~/.omp/agent/mcp.json
    ├── ln -sfn ohmypi/agents/…    ~/.omp/agent/agents/…
    └── ln -sfn ohmypi/skills/…    ~/.omp/agent/skills/…
                                   ~/.cursor/skills/…
                                   ~/.gemini/config/skills/…
```

Each tool reads its config from its canonical path; the symlink makes the repo file the
effective canonical source. Edits in the repo take effect on the next shell start (zsh),
on `prefix C-r` (tmux), on `Cmd+Shift+,` (Ghostty), and on agent restart (omp/Gemini).

## Contracts and invariants

- **One file, no copies.** Every tool config must be the repo file itself (via symlink), never
  a copy. A copy silently drifts.
- **`~/.zshrc` is a symlink.** Anything an installer appends lands inside the repo file, where
  it can be reviewed. Machine-specific secrets go in `~/.zshrc.local` (not tracked).
- **Skill packages are directories.** A skill is a directory with a `SKILL.md`; symlinking the
  directory (not the file) is what all three hosts expect.
- **`ohmypi/skills/commit` is not linked to Cursor.** That skill dispatches an omp task agent;
  Cursor has no equivalent, and its own commit flow covers that ground.
- **No install script.** [INFERENCE] Symlinks must be created manually from the `README.md`
  setup block. There is no `install.sh` or Makefile target.

## Configuration

| Config path | Tool | Mechanism |
| --- | --- | --- |
| `~/.zshrc` → `zsh/zshrc` | zsh | Sourced at every interactive shell start |
| `~/.zshrc.local` | zsh | Machine overrides, sourced last, not tracked |
| `~/.config/tmux/tmux.conf` → `tmux/tmux.conf` | tmux | Read at server start; `prefix C-r` reloads |
| `~/.config/ghostty/config` → `ghostty/config` | Ghostty | Read at launch; `Cmd+Shift+,` reloads |
| `~/.config/ghostty/themes` → `ghostty/themes/` | Ghostty | `theme = pale-knight` resolves from here |
| `~/.omp/agent/RULES.md` → `ohmypi/RULES.md` | Oh My Pi | Re-injected near every turn (sticky rule) |
| `~/.omp/agent/mcp.json` → `ohmypi/mcp.json` | Oh My Pi | Loaded at agent startup |
| `~/.omp/agent/skills/` | Oh My Pi | Rescanned on each dispatch; new skills need restart |
| `~/.cursor/skills/` | Cursor | Rescanned at window reload (**Developer: Reload Window**) |
| `~/.gemini/config/skills/` | Antigravity (agy) | Loaded at CLI startup |

## Boundaries and dependencies

**Required to be present on PATH or installed before the symlinks work:**
- **Homebrew** (`/opt/homebrew/bin/brew`) — shell plugins, eza, bat, fzf, fd, ripgrep, zoxide,
  lazygit
- **nvm** (`~/.nvm/nvm.sh`) — Node version manager; the shell silently skips its block if absent
- **Ghostty** — GPU terminal emulator; `config` and `themes` are inert until it is installed
- **tmux** — multiplexer; `tmux.conf` is inert without it
- **Oh My Pi** (`omp`) — agent harness; skills and rules are inert without it
- **Cursor** — editor; skills are inert without it
- **Antigravity CLI** (`agy`) — installed under `~/.local/bin/agy`; skills inert without it
- **JetBrains Mono**, **Symbols Nerd Font Mono** — required by Ghostty font config
- **Paper Desktop** (`~/.paper/bin/paper`) — required by `ohmypi/mcp.json` MCP server

## Tests

No automated test suite exists for the repository layout. Verification is manual:

- `ls -la ~/.zshrc` — confirm symlink target
- `zsh -n ~/.zshrc` — syntax check
- `ghostty +validate-config` — validate Ghostty config
- `tmux source-file ~/.config/tmux/tmux.conf` — check for parse errors
- `omp skill list` — confirm skill discovery [INFERENCE: command name]

## Debt and traps

- **No install script.** The `README.md` setup block must be run by hand. There is no idempotent
  installer; running `ln -sfn` a second time is safe, but ordering and `mkdir -p` guards must be
  remembered.
- **`chmod go-w "$(brew --prefix)/share"`** must be run once after Homebrew installs zsh
  completions, or `compinit` refuses to load them. Not automated.
- **Brave and Cursor configs not yet committed.** `README.md` documents intended directories
  (`brave/`, `cursor/`) that do not yet exist in the repo.
- **Skill discovery requires restarts.** New or renamed skills only become available after an omp
  restart (omp) or **Developer: Reload Window** (Cursor). The agent cannot discover them without
  a restart even if the symlink is correct.
- **Variable expansion differs by host.** `~/.paper/bin/paper` is the correct literal path for
  omp but requires `${HOME}` or `${userHome}` in plugin manifests for other hosts. The current
  `mcp.json` uses `${HOME}`, which omp expands but the upstream Paper plugin did not.

## Change guide

When adding a new tool:
1. Create `<tool>/` under the repo root with the tool's config file(s).
2. Add a symlink target in the `README.md` setup block.
3. Run `ln -sfn "$PWD/<tool>/config" "<canonical-target>"`.
4. Update `README.md` § What I use, § Intended layout, and § Setup.
5. Run `/repo-docs` (or `/docs-twins` if this repo has a monorepo mapping) to refresh docs.

When adding a new ohmypi skill:
1. Create `ohmypi/skills/<name>/SKILL.md` (plus any supporting files).
2. Add symlinks to all three host `skills/` directories that should discover it.
3. Update `AGENTS.md` skill list.
4. Restart omp/Cursor/agy so the new skill is discovered.
