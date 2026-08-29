# dotfiles

Personal configuration for my daily development setup.

> Status: this repository is currently empty — no configuration files have been
> committed yet. This README records the tools the dotfiles are intended to
> cover, so the layout is known before configs land.

## What I use

Four tools make up my environment:

| Tool | Role |
| --- | --- |
| [Brave](https://brave.com) | Browser |
| [Ghostty](https://ghostty.org) | Terminal emulator |
| Oh My Pi | Coding harness / agent environment |
| [Cursor](https://cursor.com) | Code editor |

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

## Intended layout

As configuration is added, it should land under one directory per tool:

```
dotfiles/
├── brave/      # browser preferences, extension notes
├── ghostty/    # terminal config, theme, font
├── ohmypi/     # harness settings and rules
└── cursor/     # editor settings, keybindings, extension list
```

## Setup

No install script exists yet. Once configs are committed, each tool's files are
symlinked into the location that tool expects on this machine (macOS, Apple
silicon).
