# dotfiles

Personal configuration for my daily development setup.

> Status: the shell (`zsh/`), terminal multiplexer (`tmux/`), and terminal
> (`ghostty/`) configurations are committed and live on
> this machine. The remaining tools listed below are still to land; this README
> records them so the layout is known in advance.

## What I use

Six tools make up my environment:

| Tool | Role |
| --- | --- |
| [Brave](https://brave.com) | Browser |
| [Ghostty](https://ghostty.org) | Terminal emulator |
| [Cursor](https://cursor.com) | Code editor |
| [Oh My Pi](https://omp.sh) | Terminal-first coding agent |
| [zsh](https://www.zsh.org) | Shell (macOS default) |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |

### Brave

Chromium-based browser with tracker and ad blocking built in. Used as the
default browser for both general browsing and web development, since it keeps
Chrome-compatible DevTools and extension support.

### Ghostty

GPU-accelerated terminal emulator, and the terminal every shell workflow in this
repo assumes. `ghostty/config` carries the settings and `ghostty/themes/pale-knight`
the colours — the same Pale Knight palette as tmux and zsh, so all three layers
agree on what soul-cyan and infection-amber mean.

The palette is built to be **low-contrast on purpose**. Every accent is generated
in OKLCH at one fixed lightness, so hue is the only thing that changes between
them: ANSI 1-6 all land at 6.4-6.7:1 against the background and ANSI 9-14 at
8.5-8.9:1. Equal lightness means equal attention — six colours you can tell
apart, none of which grabs the eye first. Chroma sits at 0.055-0.070, roughly
half of Tokyo Night. The background is lifted off near-black to L = 0.244 so
bright glyphs stop haloing, and body text reads at 7.6:1 rather than 12.7:1:
comfortable for a long session instead of maximally legible for one glance.
Benchmarked against Tokyo Night and Material Palenight — Palenight's calm
surface, Tokyo Night Storm's even accent weighting, both pushed further down.

The window is deliberately **opaque**. `background-opacity = 1` and
`background-blur = false` are already Ghostty's defaults; what actually leaked the
desktop through was `macos-titlebar-style`, which defaults to `transparent`. This
config pins it to `tabs`, blanks `background-image`, and sets
`unfocused-split-opacity = 1` so an inactive split reads solid instead of faded.
Nothing behind the window shows through.

Two Ghostty parser details worth remembering when editing that file:

- **No trailing comments.** `key = value  # note` makes the comment part of the
  value and the line fails to parse. Comments get their own line.
- **Custom themes** are read from the `themes` subdirectory of the config
  directory, so `theme = pale-knight` resolves to
  `~/.config/ghostty/themes/pale-knight`. Check a theme is visible with
  `ghostty +list-themes`, and check a config with `ghostty +validate-config`.

### Cursor

Editor for hands-on code work: an AI-native fork of VS Code, so VS Code
keybindings, settings, and extensions carry over.

**Skills** — Cursor discovers user-level skills from `~/.cursor/skills/` (and
`~/.agents/skills/`, plus the Claude and Codex directories for compatibility),
so `commit` is linked there from `skills/`. It is plain `git` over the staged
index, so it behaves the same in every host. `~/.cursor/skills-cursor/` is
Cursor's own directory for its built-in skills, kept in sync from a
`.sync-manifest.json`; nothing of mine goes in it.

**Paper MCP** — comes from the `paper-desktop` plugin here rather than a hand
written server: Cursor expands `${userHome}` in plugin manifests, so the
manifest spawns correctly, and its tool schemas are cached
per project under `~/.cursor/projects/<slug>/mcps/`.

### Gemini (Antigravity)

Google's AI coding assistant environment (`agy`).

**Skills** — Antigravity discovers global skills from `~/.gemini/config/skills/`
(as well as workspace skills under `.agents/skills/`). `commit` is linked into
`~/.gemini/config/skills/` from `skills/`.

### zsh

Default macOS login shell, themed **Pale Knight** in the same palette as tmux.
`zsh/zshrc` is the single source of truth — `~/.zshrc` is a symlink to it, so
edits in this repository take effect in every new shell with no copy step, and
anything an installer appends lands in the repo file where it can be reviewed.
Machine-specific or secret values go in `~/.zshrc.local`, which is sourced last
and is deliberately not tracked here.

Startup is ~80 ms: the completion dump is rebuilt at most once a day and cached
under `~/.cache/zsh`, and the prompt asks git for its state once per draw
rather than the three times `vcs_info` would.

**The prompt.** Two lines, so a long path never crowds what is being typed:

```
❖ ~/personal/opensource/dotfiles on main ✚1 ●2 ?3 ⇡4          3.0s ✘ 2
❯
```

| Mark | Meaning |
| --- | --- |
| `on main` | Current branch; `⟨rebase-i⟩` appears during an operation |
| `✚n` `●n` | Staged / unstaged files |
| `?n` `✖n` | Untracked files / merge conflicts |
| `⇡n` `⇣n` | Commits ahead of / behind upstream |
| `⚙n` | Background jobs in this shell |
| `3.0s` | How long the last command took, shown past two seconds |
| `✘ 2` | Exit status of the last command, when it failed |

The `❯` is soul-cyan after a success and infection-amber after a failure.
`user@host` is prefixed only over SSH.

**Typing.** Three plugins do the work, and load order in `zshrc` matters —
syntax highlighting must come after the widgets it wraps, and substring search
after that:

- **zsh-syntax-highlighting** colours the line as it is typed. A command that
  resolves turns soul-cyan; one that does not turns infection-amber, so a typo
  shows before Enter. A recursive `rm -rf` is branded on an amber background.
- **zsh-autosuggestions** greys in the rest of the line, guessed from history
  first and from completion second.
- **zsh-history-substring-search** makes `↑` walk only the history entries
  containing what has already been typed.

| Key | Action |
| --- | --- |
| `→` | Step into the grey suggestion |
| `C-e` | Accept all of it |
| `C-space` | Accept it **and run it** |
| `↑` `↓` | History filtered by the fragment already typed |
| `Tab` | fzf picker over the completion candidates |
| `/` (in picker) | Accept a directory and keep descending |
| `<` `>` (in picker) | Move between match groups |
| `C-/` (in picker) | Toggle the preview pane |
| `C-r` | Fuzzy history search; `C-y` copies without running |
| `C-t` | Insert a file path, with preview |
| `M-c` | Jump to a directory below here |
| `C-x C-e` | Open the current line in `$EDITOR` |

**Completion** is case- and dash-insensitive, then substring, then anywhere —
the cheapest match that works wins. `fzf-tab` replaces the menu with an fzf
picker whose preview pane is `zsh/bin/pk-preview`: a tree for directories,
syntax-highlighted text for files, a hexdump for binaries, `git diff` for
`git add`/`git restore` candidates, and `ps` for `kill`. It is a script on
`PATH` rather than a shell function because fzf runs previews in a fresh shell
that never reads `~/.zshrc`.

**`ls`.** [eza](https://github.com/eza-community/eza) with icons, directories
first, and file colours from the same palette:

| Alias | Listing |
| --- | --- |
| `ls` | Names and icons, in columns |
| `l` | Long, with git status and relative times |
| `ll` | Long, with git status and ISO timestamps |
| `la` | `ll` plus dotfiles |
| `lt` / `lta` | Tree, two levels / three levels including hidden |
| `lS` / `lm` | Sorted by size / by modification time, largest and newest first |

`cat` is [bat](https://github.com/sharkdp/bat), which also renders `man` pages;
`catp` skips the line numbers and header. `BAT_THEME=ansi` makes it highlight
through the terminal's own 16 colours rather than shipping a second, louder
palette, so it can never drift from Pale Knight. `z` is
[zoxide](https://github.com/ajeetdsouza/zoxide) — `z dotfiles` from anywhere
reaches the directory that name has meant most often, and `zi` picks from the
ranked list. `ff` fuzzy-finds a file and opens it. `mkcd` makes a directory and
steps into it; `up 3` climbs three levels.

**Node** comes from [nvm](https://github.com/nvm-sh/nvm), installed under
`~/.nvm` (not in this repository). Sourcing `nvm.sh` costs ~0.85s per shell, so
`zshrc` does not: it puts the newest installed version's `bin` directly on
PATH — `node`, `npm`, and `npx` are there in every shell — and defines an `nvm`
function that sources `nvm.sh` on first call, replaces itself, and forwards the
arguments. Startup stays at ~0.09s; `nvm install`, `nvm use`, and `nvm ls` all
work, and a `nvm use X` inside a shell overrides the PATH entry for that shell.

### tmux

Terminal multiplexer, themed **Pale Knight** — a Hollow Knight palette: dusk-blue
chrome, bone text, soul-cyan for the focused window and pane, and
infection-amber for prompts, bells, and the session badge while the prefix is
held.

The prefix is `C-s`. Windows and panes are numbered from 1 and renumbered on
close, so `prefix 1` always reaches the first window.

| Key | Action |
| --- | --- |
| `prefix` `\` or `\|` | Split left / right, in half |
| `prefix` `-` | Split top / bottom |
| `prefix` `r` | Rename this window, from an empty prompt |
| `prefix` `S` | Rename this session, from an empty prompt |
| `prefix` `x` | Close this pane, no confirmation |
| `prefix` `X` | Close this window, no confirmation |
| `prefix` `c` | New window in the current pane's directory |
| `prefix` `g` | lazygit in a popup, on the current pane's repository |
| `prefix` `v` | fzf over the Markdown files below the current pane's directory; Enter renders the pick in the browser |
| `prefix` `y` | yazi in a popup, on the current pane's directory; `o` on a Markdown file renders it in the browser |
| `prefix` `C-s` | Send a literal `C-s` to the pane |
| `prefix` `C-r` | Reload the config in place |

Splits, new windows, and the popups all inherit the current pane's
directory. Renaming starts from an empty prompt, so the new name is typed from
scratch with nothing to delete first. Mouse mode is on — drop the
`set -g mouse on` line to disable it.

`prefix g` needs [lazygit](https://github.com/jesseduffield/lazygit) on `PATH`
(`brew install lazygit`). `prefix v` needs `fd` and `fzf`, and
`zsh/bin/pk-mdopen` linked into `~/.local/bin`: it writes an HTML page under
`$TMPDIR/pk-mdopen/` that renders the file client-side with
[marked](https://github.com/markedjs/marked) and github-markdown-css (both
from jsdelivr), so the Markdown itself never leaves the machine, then opens it
in the default browser. Relative images and links resolve against the file's
own directory.

`prefix y` needs [yazi](https://github.com/sxyazi/yazi) (`brew install yazi`)
and `yazi/yazi.toml` linked into `~/.config/yazi/`. That config sends `.md`
and `.markdown` files to `pk-mdopen` on `o` / Enter, with the editor offered
under `O`; every other file type keeps yazi's default opener. The popup stays
open after a render, so several files can be opened in a row; `q` closes it.

### herdr

[herdr](https://herdr.dev) — terminal workspace manager for AI coding agents —
themed **Pale Knight** through `[theme.custom]` in `herdr/config.toml`: every
colour token is overridden with the tmux palette, so the tab bar and overlays
sit on crypt, focus is soul-cyan, and agent states use the equal-lightness
ANSI accents (working is infection-amber, blocked is red, done is green). The
sidebar keeps the terminal's own background. Keybindings are herdr's defaults
(prefix `C-b`); `herdr --default-config` lists them.

Reload with `prefix shift+r` or `herdr server reload-config`. herdr's Settings
screen writes back into the linked file (theme name, status indicators,
sound, toasts), so check `git diff` after using it. A theme picked there
changes only `name`; the custom tokens still apply on top.

### herdr app

The [herdr desktop app](https://herdr.dev) is a separate program from the TUI
above, with its own config in `~/.config/herdr-app`. `herdr-app/` keeps only the
files changed here, each linked in one by one so the app's generated
`gpui-kit.d.ts` / `jsconfig.json` stay out of the repo:

- `keys.json` — the app's default keys plus `ctrl-s` → `mod.open:prefix`.
  Once edited, app updates no longer add new default shortcuts to it.
- `mods/prefix/` — a tmux-style prefix: `ctrl-s` opens a key panel, the next
  key runs and closes it. `c` new tab, `1-9` select tab, `r`/`S` rename
  tab/space, `s` spaces list, `a` agents list, `X`/`x` close tab/pane,
  `\`/`|`/`-` split, `hjkl` move, `m` zoom, `e` nvim in a new tab, `g` lazygit,
  `v` markdown picker, `ctrl-s` a literal `ctrl-s`. Esc or any other key
  closes it.
- `mods/spaces-keys/` — a clone of the shipped `spaces` sidebar that takes the
  keyboard: `j`/`k` or ↑/↓ move, Enter shows the space, Esc returns to the panes.
- `mods/agents-keys/` — the same for the shipped `agents` list: `j`/`k` or ↑/↓ move over
  the agents shown (sub-agents and folded groups skipped), Enter focuses the
  agent's pane, Esc returns to the panes.
- `layouts/main-keys.json` — a clone of the shipped `main` layout with its
  spaces and agents blocks on `spaces-keys` and `agents-keys`. Select it with
  `ctrl-shift-l` or `herdr-app do layout.switch --name main-keys`.

The clones don't follow Herdr's updates to `spaces`, `agents` and `main`.
The app watches `~/.config/herdr-app`, not this repo, so an edit made here is
not picked up on its own: rerun the link loop under Setup (recreating a link
is a change in the app's folder) or restart the app. `ctrl-alt-shift-escape`
resets keys and layout.

## Skills

Only `commit` is kept for now; every other skill was removed on 2026-11-05.
It exists in three copies, one per host:

- `skills/commit/` — plain Agent Skill, linked into Cursor
  (`~/.cursor/skills/`) and Gemini (`~/.gemini/config/skills/`).
- `claude/skills/commit/` — Claude Code. `claude/link-skills` links each
  skill under `claude/skills/` into both accounts — `~/.claude/skills/` (`cc`)
  and `~/.claude-work/skills/` (`ccw`) — prunes links to removed skills, and
  links `claude/CLAUDE.md` as each account's global instructions. Each
  account's `skills/synced/` (skills synced from claude.ai) is left alone.
- `codex/skills/commit/` — Codex. `codex/link-skills` links each skill under
  `codex/skills/` into `~/.agents/skills/`, prunes its own broken links, and
  refuses to overwrite another skill. Invoke with `$commit`.

Rerun the link scripts after adding or removing a skill.

**`commit`** (`/commit`, `$commit`) — stops if `user.name` or `user.email` is
not set. Commits what is staged; when nothing is, it stages everything first.
One commit by default; several focused commits only where the changes
separate cleanly (`plan` previews). In a new repository it instead splits
the whole project into granular commits in build order (basics, skeleton,
foundations, one per feature with its tests, docs, CI), never one
`initial commit`. Each message is a semantic `type(scope): summary` with two
or more bullets, and never carries a `Co-Authored-By:` or any other
attribution trailer.

## Intended layout

As configuration is added, it should land under one directory per tool:

```
dotfiles/
├── brave/      # browser preferences, extension notes
├── ghostty/    # terminal config
│   ├── config
│   └── themes/pale-knight
├── claude/     # Claude Code, both accounts (cc, ccw)
│   ├── CLAUDE.md                   # global instructions
│   ├── link-skills                 # links claude/skills/* into both
│   └── skills/commit/SKILL.md
├── codex/      # Codex
│   ├── link-skills                 # links codex/skills/* into ~/.agents/skills
│   └── skills/commit/SKILL.md
├── skills/     # Agent Skills, linked into Cursor and Gemini
│   └── commit/SKILL.md
├── cursor/     # editor settings, keybindings, extension list
├── zsh/        # zshrc, and bin/pk-preview for the fzf preview pane
├── tmux/       # tmux.conf, Pale Knight theme and keys
├── herdr/      # config.toml, Pale Knight theme
├── herdr-app/  # desktop app: keys.json, ctrl-s prefix mod, keyboard spaces/agents lists
└── yazi/       # yazi.toml, Markdown opens through pk-mdopen
```

## Setup

No install script exists yet. Each tool's files are symlinked into the location
that tool expects. Two kinds of machine use this repo, and they take different
slices of it:

- **macOS (Apple silicon)** — the whole workshop: Ghostty, zsh, tmux, Neovim,
  Cursor, Gemini.
- **Ubuntu server** — bash, tmux, Neovim, and git. Ghostty, zsh, Cursor,
  Gemini and their links stay out.

### macOS

The shell depends on Homebrew packages. Nothing in `zsh/zshrc` breaks without
them — every block is guarded — but the shell is only itself with all of them:

```sh
brew install \
  zsh-syntax-highlighting zsh-autosuggestions zsh-completions \
  zsh-history-substring-search fzf-tab \
  eza bat fzf fd ripgrep zoxide
brew install --cask font-symbols-only-nerd-font   # the icons eza prints
```

`compinit` refuses to load completions from a group-writable directory, which
is how Homebrew leaves `share`. Once, after installing:

```sh
chmod go-w "$(brew --prefix)/share"
```

Node is not a Homebrew package here — nvm owns it, and the `nvm` block in
`zsh/zshrc` stays silent until `~/.nvm/nvm.sh` exists:

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash
nvm install --lts     # or any version; the newest installed one lands on PATH
```

The installer appends its own two-line loader to `~/.zshrc`; delete that — it is
the ~0.85s load the block above exists to avoid.

Already linked:

```sh
ln -sfn "$PWD/zsh/zshrc"       ~/.zshrc
mkdir -p ~/.local/bin ~/.config/tmux ~/.config/yazi ~/.config/ghostty ~/.config/herdr ~/.cursor/skills
ln -sfn "$PWD/zsh/bin/pk-preview" ~/.local/bin/pk-preview
ln -sfn "$PWD/zsh/bin/pk-mdopen" ~/.local/bin/pk-mdopen
ln -sfn "$PWD/tmux/tmux.conf"  ~/.config/tmux/tmux.conf
ln -sfn "$PWD/yazi/yazi.toml"  ~/.config/yazi/yazi.toml
ln -sfn "$PWD/ghostty/config" ~/.config/ghostty/config
ln -sfn "$PWD/ghostty/themes" ~/.config/ghostty/themes
ln -sfn "$PWD/herdr/config.toml" ~/.config/herdr/config.toml
mkdir -p ~/.config/herdr-app/mods/{prefix,spaces-keys,agents-keys} ~/.config/herdr-app/layouts
for f in keys.json layouts/main-keys.json mods/{prefix,spaces-keys,agents-keys}/{main.js,mod.json}; do
  ln -sfn "$PWD/herdr-app/$f" ~/.config/herdr-app/$f
done
ln -sfn "$PWD/skills/commit"     ~/.cursor/skills/commit
ln -sfn "$PWD/skills/archify"    ~/.cursor/skills/archify

mkdir -p ~/.gemini/config/skills
ln -sfn "$PWD/skills/commit" ~/.gemini/config/skills/commit
ln -sfn "$PWD/skills/archify" ~/.gemini/config/skills/archify

npx skills add DietrichGebert/ponytail -g --skill ponytail

./claude/link-skills
```

### Ubuntu server

A headless box reached over ssh (Tailscale) from the Mac. It runs tmux and
Neovim in bash — `bash/bashrc` is that shell's share of
`zsh/zshrc` and needs no Homebrew, Ghostty, eza, bat or fzf. Nothing under
`ghostty/`, `zsh/`, `skills/`, or the Cursor and Gemini link lists above
belongs here.

Packages, all from apt:

```sh
sudo apt install git tmux neovim ripgrep build-essential
```

`build-essential` is for Treesitter — `nvim/init.lua` compiles its parsers with
`cc` on first launch and silently falls back to plain syntax colour without it.

Links — only the Linux slice:

```sh
ln -sfn "$PWD/bash/bashrc"     ~/.bashrc
mkdir -p ~/.config/tmux ~/.config/nvim
ln -sfn "$PWD/tmux/tmux.conf"  ~/.config/tmux/tmux.conf
ln -sfn "$PWD/nvim/init.lua"      ~/.config/nvim/init.lua
ln -sfn "$PWD/nvim/lazy-lock.json" ~/.config/nvim/lazy-lock.json
```

`git/config` needs no link — `bash/bashrc` points `GIT_CONFIG_GLOBAL` at it,
and it includes `~/.gitconfig` for the machine's identity.

**Ghostty over ssh.** Ghostty sets `TERM=xterm-ghostty`, and ssh forwards it.
A stock Ubuntu has no terminfo entry by that name, so tmux, nvim, less and
`clear` all fail with `'xterm-ghostty': unknown terminal type`. `bash/bashrc`
falls back to `xterm-256color` whenever `infocmp "$TERM"` fails, which is
enough. To have the real entry instead (keeps Ghostty's own capabilities), run
once from the Mac:

```sh
infocmp -x xterm-ghostty | ssh <server> -- tic -x -
```

Ghostty can also do this on every connection by itself with
`shell-integration-features = ssh-terminfo` in `ghostty/config`.

Any pre-existing real `~/.zshrc` was copied to `~/.zshrc.backup.<timestamp>`
before the link was created. `reload` (`exec zsh`) picks up shell edits in the
current window. A running tmux server picks up edits to `tmux/tmux.conf` with
`prefix C-r`; new servers read it on start. Ghostty reloads with
`Cmd+Shift+,` — a config change does not reach already-open windows until then.
Cursor also reads its skill directories at startup: **Developer: Reload Window**
is enough, and the skill then appears under Customize → Skills and as
`/commit` in Agent chat.
