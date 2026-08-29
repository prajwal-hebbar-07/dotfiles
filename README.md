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
repo assumes. Configuration is a single plain-text key/value file, which makes it
straightforward to version here.

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

Default macOS login shell. `zsh/zshrc` is the single source of truth for it —
`~/.zshrc` is a symlink to that file, so edits made in this repository take
effect in every new shell with no copy step. Anything an installer appends to
`~/.zshrc` lands in the repo file instead, where it can be reviewed and
committed.

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
├── ghostty/    # terminal config, theme, font
├── ohmypi/     # harness skills and task agents
│   ├── skills/commit/SKILL.md
│   └── agents/committer.md
├── cursor/     # editor settings, keybindings, extension list
├── zsh/        # zshrc, shell exports and aliases
└── tmux/       # tmux.conf, Pale Knight theme and keys
```

## Setup

No install script exists yet. Each tool's files are symlinked into the location
that tool expects on this machine (macOS, Apple silicon).

Already linked:

```sh
ln -sfn "$PWD/zsh/zshrc"       ~/.zshrc
mkdir -p ~/.config/tmux ~/.omp/agent/skills ~/.omp/agent/agents
ln -sfn "$PWD/tmux/tmux.conf"  ~/.config/tmux/tmux.conf
ln -sfn "$PWD/ohmypi/skills/commit"     ~/.omp/agent/skills/commit
ln -sfn "$PWD/ohmypi/agents/committer.md" ~/.omp/agent/agents/committer.md
```

Any pre-existing real `~/.zshrc` was copied to `~/.zshrc.backup.<timestamp>`
before the link was created. A running tmux server picks up edits to
`tmux/tmux.conf` with `prefix C-r`; new servers read it on start. Task agents are
rediscovered on every dispatch, but skills are read at startup — a new or renamed
skill needs an omp restart before `/skill:<name>` sees it.
