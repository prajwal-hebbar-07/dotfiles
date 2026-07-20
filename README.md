# Dotfiles

This repository contains terminal-focused configuration files that can be linked
into the system configuration directory.

## Install

Install the required linker:

```sh
brew install stow
```

Clone the repo, then link the config files into `$HOME`:

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script runs GNU Stow for these packages:

```sh
stow --target="$HOME" --restow zsh tmux wezterm starship git helix nvim codex
```

## Claude

The default config plus two extra logins (`claude-one` and `claude-two`, each a
separate `CLAUDE_CONFIG_DIR`) share one repo-tracked config. Each keeps its own
sessions, caches, and credentials as a real directory, and `install.sh`
symlinks the shared pieces into it.

All three share one skills folder (`claude/skills`); `claude-one`/`claude-two`
additionally share one login-agnostic `claude/settings.json`:

```sh
~/.claude/skills           -> <repo>/claude/skills
~/.claude-one/skills        -> <repo>/claude/skills
~/.claude-two/skills        -> <repo>/claude/skills
~/.claude-one/settings.json -> <repo>/claude/settings.json
~/.claude-two/settings.json -> <repo>/claude/settings.json
```

Pick a login with `CLAUDE_CONFIG_DIR`; the `cc1`/`cc2` zsh aliases wrap this.
The shared skills include `commit` (commits only the already-staged changes
with a semantic message, then pulls with a merge and pushes), `plan`
(researches the repo and writes a senior-engineer-ready implementation plan,
with diagrams where useful, into the project's `plans/` directory),
`plan-review` (resolves the inline `@me` comments left in a plan and logs each
review round inside it), and `plan-ask` (read-only back-and-forth Q&A about a
plan — explains the reasoning, tradeoffs, and risks without editing it).

## Codex

The Codex skills live in `codex/.codex/skills`. `install.sh` symlinks each one
into `~/.codex/skills` while the rest of `~/.codex` stays a real directory for
Codex runtime state:

```sh
~/.codex/skills/<skill> -> <repo>/codex/.codex/skills/<skill>
```

The `commit` skill handles `$commit` as one guarded Git flow:

- Commits only the already-staged changes; never stages anything itself.
- Writes one Conventional Commits message with a few explanatory bullets and no
  AI attribution.
- Pulls with a merge (`--no-rebase`), never a rebase, then pushes.
- Stops for guidance on merge conflicts and never force-pushes.

## WezTerm

The WezTerm configuration lives in `wezterm/.config/wezterm/wezterm.lua`.

It configures WezTerm as a clean terminal window that is ready to be used with a
terminal multiplexer such as tmux:

- Uses the `Catppuccin Mocha` dark color scheme.
- Hides WezTerm's own tab bar because tmux will handle sessions, windows, and
  panes.
- Uses resize-only window decorations. This keeps the window visually minimal
  while still allowing normal resizing behavior.
- Uses `JetBrains Mono` as the main terminal font.
- Adds `Symbols Nerd Font Mono` as a fallback so icons from terminal tools can
  render correctly.
- Sets the font size to `13.0`.
- Increases line spacing slightly with `line_height = 1.12`, making dense
  terminal output easier to read.

The system config path is expected to point to this repo:

```sh
~/.config/wezterm -> <repo>/wezterm/.config/wezterm
```

## tmux

The tmux configuration lives in `tmux/.config/tmux/tmux.conf`.

It configures tmux as the main place for tabs, panes, movement, and copy mode:

- Changes the tmux prefix from `Ctrl-b` to `Ctrl-s`.
- Keeps `Ctrl-s Ctrl-s` available for sending the prefix key into nested tmux or
  remote sessions.
- Enables mouse support.
- Starts window and pane numbering at `1`.
- Automatically renumbers windows after a window is closed.
- Enables focus events for better editor and terminal integration.
- Uses `tmux-256color` and enables RGB color support, including WezTerm-specific
  RGB support.
- Adds vim-style pane movement with `h`, `j`, `k`, and `l`.
- Adds vim-style pane resizing with uppercase `H`, `J`, `K`, and `L`.
- Opens new split panes in the current pane's working directory.
- Uses vi-style copy mode.
- Copies selected text into the macOS clipboard with `pbcopy`.
- Opens focused popups for `lazygit`, `yazi`, `tree`, and `sesh`.
- Uses a Catppuccin Mocha-inspired status bar and pane border theme.

The system config path is expected to point to this repo:

```sh
~/.config/tmux -> <repo>/tmux/.config/tmux
```

See `shortcuts.md` for the keyboard shortcuts.

## Starship

The Starship prompt configuration lives in
`starship/.config/starship/starship.toml`.

It configures a Catppuccin Mocha prompt with useful context at the command line:

- Current directory with smart truncation.
- Git branch and compact repository status.
- Node.js, Python, and package versions when relevant.
- Command duration for slower commands.
- Background jobs and failed command exit status.

Install Starship with:

```sh
brew install starship
```

The standard config path is expected to point to this repo:

```sh
~/.config/starship -> <repo>/starship/.config/starship
```

## Helix

The Helix configuration lives in `helix/.config/helix`:

- `config.toml` — editor behaviour and keymaps.
- `languages.toml` — per-language servers and formatters.
- `themes/rose_pine_transparent.toml` — the custom theme.

It configures Helix as a lightweight, keyboard-driven editor:

- Uses a custom `rose_pine_transparent` theme: upstream Rosé Pine with a
  cleared editor background (so a transparent terminal shows through) and
  enriched syntax highlighting for the JS/TS/React, Go, and Python stacks.
- Uses relative line numbers, a highlighted cursor line, and no rulers.
- Shows a bufferline when more than one file is open and enables soft wrap.
- Renders indent guides and mode-aware cursor shapes.
- Enables LSP diagnostics messages and inlay hints.
- Adds centered half-page scrolling with `Ctrl-d`/`Ctrl-u` and `space w`/
  `space q` for write/quit.

`languages.toml` wires up tooling for JS/TS/JSX/TSX (React, Next.js, Node,
Express, Nest), Go, Python, Dockerfile, YAML (incl. docker-compose), Nginx, and
Tailwind CSS — format-on-save with `prettier`/`goimports`/`ruff` and the
matching language servers, including `tailwindcss-language-server` for class
completion.

Install the editor with:

```sh
brew install helix
```

Helix does not bundle language servers or formatters; install the ones you use
so `languages.toml` can find them on `$PATH`:

```sh
brew install gopls ruff
go install golang.org/x/tools/cmd/goimports@latest
npm install -g typescript typescript-language-server prettier \
  @tailwindcss/language-server vscode-langservers-extracted \
  dockerfile-language-server-nodejs yaml-language-server
```

Run `hx --health <language>` to see what Helix finds versus what is missing.
Nginx and docker-compose need no extra tooling (grammar / YAML defaults).

The system config path is expected to point to this repo:

```sh
~/.config/helix -> <repo>/helix/.config/helix
```

## Neovim

The Neovim configuration lives in `nvim/.config/nvim`. `init.lua` bootstraps
`lazy.nvim` with an empty plugin spec, while `lua/config/options.lua` and
`lua/config/keymaps.lua` contain the built-in editor settings. No other plugins
are included.

Install Neovim with:

```sh
brew install neovim
```

The system config path is expected to point to this repo:

```sh
~/.config/nvim -> <repo>/nvim/.config/nvim
```

## Git

The Git configuration lives in `git/.config/git/config`.

It configures `git-delta` as the pager for readable side-by-side diffs:

- Shows changed files with decorated headers.
- Shows old and new code side by side.
- Shows line numbers on both sides.
- Keeps moved-line coloring and better merge conflict markers enabled.

Install the diff viewer with:

```sh
brew install git-delta
```

The system config path is expected to point to this repo:

```sh
~/.config/git -> <repo>/git/.config/git
```

## zsh

The zsh configuration lives in `zsh/.zshrc`.

It configures the interactive shell for command discovery and nicer typing:

- Enables larger shared command history with duplicate cleanup.
- Adds case-insensitive tab completion and selectable completion menus.
- Adds history-prefix search with the up/down arrow keys and `Ctrl-p`/`Ctrl-n`.
- Loads `zsh-autosuggestions` from Homebrew for inline command suggestions.
- Loads `zsh-syntax-highlighting` from Homebrew so commands are colored as you
  type.
- Loads `fzf` from Homebrew for visual command history, file, and folder search.
- Uses GNU `ls` for fast colored directory listings and `tree` for directory maps.
- Uses `ripgrep` aliases for hidden-file-aware text and file search.
- Uses `sesh` with `gum` for tmux session picking.
- Adds `cc1` and `cc2` Claude aliases for `~/.claude-two` and
  `~/.claude-one` with dangerous permission prompts skipped.
- Adds GNU coreutils to the front of `PATH` when available.
- Initializes Starship for a richer prompt.
- Keeps the local aliases and Node/pnpm path setup.

Install the shell tools with:

```sh
brew install zsh-autosuggestions zsh-syntax-highlighting fzf starship ripgrep gum yazi tree coreutils
brew install joshmedeski/sesh/sesh
```

The home config path is expected to point to this repo:

```sh
~/.zshrc -> <repo>/zsh/.zshrc
```
