# dotfiles

Personal configuration for my daily development setup.

> Status: the shell configuration (`zsh/`) is committed and live on this
> machine. The remaining tools listed below are still to land; this README
> records them so the layout is known in advance.

## What I use

Five tools make up my environment:

| Tool | Role |
| --- | --- |
| [Brave](https://brave.com) | Browser |
| [Ghostty](https://ghostty.org) | Terminal emulator |
| Oh My Pi | Coding harness / agent environment |
| [Cursor](https://cursor.com) | Code editor |
| [zsh](https://www.zsh.org) | Shell (macOS default) |

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
verification against this machine rather than a hosted sandbox. Its settings and
rules belong in this repo so behavior is reproducible across machines.

### Cursor

Editor for hands-on code work: an AI-native fork of VS Code, so VS Code
keybindings, settings, and extensions carry over.

### zsh

Default macOS login shell. `zsh/zshrc` is the single source of truth for it —
`~/.zshrc` is a symlink to that file, so edits made in this repository take
effect in every new shell with no copy step. Anything an installer appends to
`~/.zshrc` lands in the repo file instead, where it can be reviewed and
committed.

## Intended layout

As configuration is added, it should land under one directory per tool:

```
dotfiles/
├── brave/      # browser preferences, extension notes
├── ghostty/    # terminal config, theme, font
├── ohmypi/     # harness settings and rules
├── cursor/     # editor settings, keybindings, extension list
└── zsh/        # zshrc, shell exports and aliases
```

## Setup

No install script exists yet. Each tool's files are symlinked into the location
that tool expects on this machine (macOS, Apple silicon).

zsh, already linked:

```sh
ln -sfn "$PWD/zsh/zshrc" ~/.zshrc
```

Any pre-existing real `~/.zshrc` was copied to `~/.zshrc.backup.<timestamp>`
before the link was created.
