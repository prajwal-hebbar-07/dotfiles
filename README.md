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
stow --target="$HOME" --restow zsh tmux wezterm starship git nvim claude-one claude-two codex
```

## Codex

The Codex skills live in `codex/.codex/skills`.

The `ship` skill handles `/ship` and related requests as one guarded Git flow:

- Stages all changes once.
- Creates one Conventional Commits commit without AI attribution.
- Pulls with a merge, never a rebase.
- Stops for guidance on conflicts and never force-pushes automatically.

The skill is expected to point to this repo while the rest of `~/.codex`
remains a real directory for Codex runtime state:

```sh
~/.codex/skills/ship -> <repo>/codex/.codex/skills/ship
```

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
- Adds prefix-free pane movement with `Ctrl-h`, `Ctrl-j`, `Ctrl-k`, and
  `Ctrl-l`.
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

## Neovim

The Neovim configuration lives in `nvim/.config/nvim`.

It configures Neovim as a complete, keyboard-driven coding workspace:

- Uses `lazy.nvim` for plugin management.
- Uses Catppuccin Mocha with a transparent, minimal editor interface.
- Uses Space as the global and local leader key.
- Adds `oil.nvim` for directory and file operations.
- Adds Neo-tree for a persistent, Git-aware project sidebar.
- Adds Telescope for file, buffer, help, Git file, and text search.
- Adds `grug-far.nvim` for previewable project-wide search and replace.
- Adds `aerial.nvim` for a navigable code outline.
- Adds Treesitter for syntax highlighting and indentation.
- Adds `blink.cmp` for autocomplete with LSP, path, buffer, and snippet sources.
- Adds `which-key.nvim` to make the keymap hierarchy discoverable.
- Adds automatic bracket pairs.
- Adds markdown rendering inside Neovim.
- Adds `gitsigns.nvim` and `vim-fugitive` for Git workflows.
- Adds small editing helpers from `mini.nvim`.
- Adds tmux-aware split navigation with `vim-tmux-navigator`.
- Adds automatic project sessions through `persistence.nvim`.
- Adds background build, run, and test tasks through `overseer.nvim`, including
  npm, Make, Cargo, Pytest, current-file execution, and `.vscode/tasks.json`
  discovery.
- Adds DAP debugging for Python and JavaScript/TypeScript with breakpoints,
  stepping, expression evaluation, a REPL, and an inspector UI.
- Adds Mason-managed LSP servers for Lua, JavaScript/TypeScript, Python, Bash,
  JSON, YAML, and Markdown.
- Adds format-on-save and manual formatting through `conform.nvim`.
- Adds linters through `nvim-lint`.

Install the editor and search helpers with:

```sh
brew install neovim ripgrep fd tree-sitter-cli
```

Mason installs language servers, formatter/linter binaries, and the Python and
JavaScript debug adapters on first startup. Node.js is required for the
JavaScript/TypeScript tooling.

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
- Uses `eza` for richer directory listings and `tree` for quick directory maps.
- Uses `ripgrep` aliases for hidden-file-aware text and file search.
- Uses `sesh` with `gum` for tmux session picking.
- Adds `cc1` and `cc2` Claude aliases for `~/.claude-two` and
  `~/.claude-one` with dangerous permission prompts skipped.
- Adds GNU coreutils to the front of `PATH` when available.
- Initializes Starship for a richer prompt.
- Keeps the local aliases and Node/pnpm path setup.

Install the shell tools with:

```sh
brew install zsh-autosuggestions zsh-syntax-highlighting fzf starship eza ripgrep gum yazi tree coreutils
brew install joshmedeski/sesh/sesh
```

The home config path is expected to point to this repo:

```sh
~/.zshrc -> <repo>/zsh/.zshrc
```
