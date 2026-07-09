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
stow --target="$HOME" --restow zsh tmux wezterm starship git nvim herdr
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

## Herdr

The Herdr configuration lives in `herdr/.config/herdr/config.toml`.

It configures Herdr as a tmux-like terminal workspace manager for agent-heavy
work:

- Uses the same `Ctrl-s` prefix as tmux.
- Adds `prefix+/` for searching Herdr keymaps by intent.
- Adds `prefix+q` for stopping the Herdr server.
- Adds a guarded `prefix+Q` exit flow that stops the Herdr server and closes
  all workspaces, tabs, panes, and pane processes.
- Keeps pane movement on `prefix` plus `h`, `j`, `k`, and `l`.
- Adds direct pane movement on `Ctrl-h`, `Ctrl-j`, `Ctrl-k`, and `Ctrl-l`.
- Uses `j` and `k` inside the workspace picker for workspace movement.
- Adds `prefix+a` for an fzf picker over running agents (`herdr agent list` /
  `herdr agent focus`); pressing `1`-`9` jumps straight to that row, or type
  to fuzzy-search.
- Uses `prefix+c` for new tabs and `prefix+,` for renaming tabs.
- Uses `prefix+Shift-p` for renaming panes.
- Uses `prefix+\` and `prefix+-` for right and down splits, matching the tmux
  split habit in this repo.
- Uses uppercase `H`, `J`, `K`, and `L` after the prefix for pane resizing.
- Uses `prefix+m` for pane zoom.
- Uses `prefix+g`, `prefix+y`, and `prefix+t` for `lazygit`, `yazi`, and a
  project tree pane.
- Uses the Catppuccin theme with the same accent color as the tmux status bar.

Install Herdr with:

```sh
brew install herdr
```

To keep the Herdr server running in the background:

```sh
brew services start herdr
```

The config file is expected to point to this repo. The parent directory stays
real because Herdr writes logs and sockets next to the config file:

```sh
~/.config/herdr/config.toml -> <repo>/herdr/.config/herdr/config.toml
```

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

It configures Neovim as a small code-reading and coding setup:

- Uses `lazy.nvim` for plugin management.
- Uses Catppuccin Mocha for the editor theme.
- Adds `oil.nvim` for directory and file operations.
- Adds Telescope for file, buffer, help, Git file, and text search.
- Adds Treesitter for syntax highlighting and indentation.
- Adds `blink.cmp` for autocomplete with LSP, path, buffer, and snippet sources.
- Adds automatic bracket pairs.
- Adds markdown rendering inside Neovim.
- Adds `gitsigns.nvim` and `vim-fugitive` for Git workflows.
- Adds small editing helpers from `mini.nvim`.
- Adds tmux-aware split navigation with `vim-tmux-navigator`.
- Adds Mason-managed LSP servers for Lua, JavaScript/TypeScript, Python, Bash,
  JSON, YAML, and Markdown.
- Adds formatters through `conform.nvim`.
- Adds linters through `nvim-lint`.

Install the editor and search helpers with:

```sh
brew install neovim ripgrep fd tree-sitter-cli
```

Mason installs language servers and formatter/linter binaries on first startup.

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
- Adds `herdr-stop-all` for stopping every named Herdr session.
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
