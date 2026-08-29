# dotfiles

Personal configuration for my daily development setup.

> Status: the shell (`zsh/`), terminal multiplexer (`tmux/`), and harness
> (`ohmypi/`) configurations are committed and live on this machine. The
> remaining tools listed below are still to land; this README records them so
> the layout is known in advance.

## What I use

Six tools make up my environment:

| Tool | Role |
| --- | --- |
| [Brave](https://brave.com) | Browser |
| [Ghostty](https://ghostty.org) | Terminal emulator |
| Oh My Pi | Coding harness / agent environment |
| [Cursor](https://cursor.com) | Code editor |
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
agree on what soul-cyan and infection-orange mean.

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

### Oh My Pi

The coding harness I work through — agent-driven editing, search, and
verification against this machine rather than a hosted sandbox. `ohmypi/` holds
its skills and task agents, symlinked into `~/.omp/agent/`.

**`commit` skill** (`/skill:commit`) — turns staged changes into one semantic
commit. It checks that `user.name` and `user.email` are set, refuses to run with
an empty index, writes a `type(scope): summary` subject followed by pointer
bullets, and adds no `Co-Authored-By:` or "Generated with" trailer, so git
history carries no harness attribution. It never runs `git add` — staging stays
my decision.

**`committer` agent** — the skill's whole job is delegation. It dispatches this
agent, which runs `anthropic/claude-haiku-4-5` at `thinking-level: minimal` with
`bash` as its only tool, so the diff is read by the cheap model and never enters
the main session's context.

### Cursor

Editor for hands-on code work: an AI-native fork of VS Code, so VS Code
keybindings, settings, and extensions carry over.

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

The `❯` is soul-cyan after a success and infection-orange after a failure.
`user@host` is prefixed only over SSH.

**Typing.** Three plugins do the work, and load order in `zshrc` matters —
syntax highlighting must come after the widgets it wraps, and substring search
after that:

- **zsh-syntax-highlighting** colours the line as it is typed. A command that
  resolves turns soul-cyan; one that does not turns infection-orange, so a typo
  shows before Enter. A recursive `rm -rf` is branded on an orange background.
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
`catp` skips the line numbers and header. `z` is
[zoxide](https://github.com/ajeetdsouza/zoxide) — `z dotfiles` from anywhere
reaches the directory that name has meant most often, and `zi` picks from the
ranked list. `ff` fuzzy-finds a file and opens it. `mkcd` makes a directory and
steps into it; `up 3` climbs three levels.

### tmux

Terminal multiplexer, themed **Pale Knight** — a Hollow Knight palette: void
black chrome, bone-white text, soul-cyan for the focused window and pane, and
infection-orange for prompts, bells, and the session badge while the prefix is
held.

The prefix is `C-s`. Windows and panes are numbered from 1 and renumbered on
close, so `prefix 1` always reaches the first window.

| Key | Action |
| --- | --- |
| `prefix` `\` or `\|` | Split left / right |
| `prefix` `-` | Split top / bottom |
| `prefix` `r` | Rename this window, from an empty prompt |
| `prefix` `S` | Rename this session, from an empty prompt |
| `prefix` `x` | Close this pane, no confirmation |
| `prefix` `X` | Close this window, no confirmation |
| `prefix` `c` | New window in the current pane's directory |
| `prefix` `g` | lazygit in a popup, on the current pane's repository |
| `prefix` `C-s` | Send a literal `C-s` to the pane |
| `prefix` `C-r` | Reload the config in place |

Splits, new windows, and the lazygit popup all inherit the current pane's
directory. Renaming starts from an empty prompt, so the new name is typed from
scratch with nothing to delete first. Mouse mode is on — drop the
`set -g mouse on` line to disable it.

`prefix g` needs [lazygit](https://github.com/jesseduffield/lazygit) on `PATH`
(`brew install lazygit`).

## Intended layout

As configuration is added, it should land under one directory per tool:

```
dotfiles/
├── brave/      # browser preferences, extension notes
├── ghostty/    # terminal config
│   ├── config
│   └── themes/pale-knight
├── ohmypi/     # harness skills and task agents
│   ├── skills/commit/SKILL.md
│   └── agents/committer.md
├── cursor/     # editor settings, keybindings, extension list
├── zsh/        # zshrc, and bin/pk-preview for the fzf preview pane
└── tmux/       # tmux.conf, Pale Knight theme and keys
```

## Setup

No install script exists yet. Each tool's files are symlinked into the location
that tool expects on this machine (macOS, Apple silicon).

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

Already linked:

```sh
ln -sfn "$PWD/zsh/zshrc"       ~/.zshrc
mkdir -p ~/.local/bin ~/.config/tmux ~/.config/ghostty ~/.omp/agent/skills ~/.omp/agent/agents
ln -sfn "$PWD/zsh/bin/pk-preview" ~/.local/bin/pk-preview
ln -sfn "$PWD/tmux/tmux.conf"  ~/.config/tmux/tmux.conf
ln -sfn "$PWD/ghostty/config" ~/.config/ghostty/config
ln -sfn "$PWD/ghostty/themes" ~/.config/ghostty/themes
ln -sfn "$PWD/ohmypi/skills/commit"     ~/.omp/agent/skills/commit
ln -sfn "$PWD/ohmypi/agents/committer.md" ~/.omp/agent/agents/committer.md
```

Any pre-existing real `~/.zshrc` was copied to `~/.zshrc.backup.<timestamp>`
before the link was created. `reload` (`exec zsh`) picks up shell edits in the
current window. A running tmux server picks up edits to `tmux/tmux.conf` with
`prefix C-r`; new servers read it on start. Ghostty reloads with
`Cmd+Shift+,` — a config change does not reach already-open windows until then.
Task agents are rediscovered on every dispatch, but skills are read at startup —
a new or renamed skill needs an omp restart before `/skill:<name>` sees it.
