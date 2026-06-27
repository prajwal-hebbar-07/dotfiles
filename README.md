# Dotfiles

This repository contains terminal-focused configuration files that can be linked
into the system configuration directory.

## WezTerm

The WezTerm configuration lives in `wezterm/wezterm.lua`.

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
~/.config/wezterm -> ~/chaotic-thoughts/dotfiles/wezterm
```

## tmux

The tmux configuration lives in `tmux/tmux.conf`.

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
- Uses a Catppuccin Mocha-inspired status bar and pane border theme.

The system config path is expected to point to this repo:

```sh
~/.config/tmux -> ~/chaotic-thoughts/dotfiles/tmux
```

See `shortcuts.md` for the keyboard shortcuts.

## Starship

The Starship prompt configuration lives in `starship/starship.toml`.

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
~/.config/starship.toml -> ~/chaotic-thoughts/dotfiles/starship/starship.toml
```

## Neovim

The Neovim configuration lives in `nvim`.

It configures Neovim as a small code-reading and coding setup:

- Uses `lazy.nvim` for plugin management.
- Uses Catppuccin Mocha for the editor theme.
- Adds `nvim-tree` for a file explorer.
- Adds `fzf-lua` for file, buffer, help, and text search.
- Adds Treesitter for syntax highlighting and indentation.
- Adds `nvim-cmp` for autocomplete with LSP, path, buffer, and snippet sources.
- Adds automatic bracket pairs.
- Adds Mason-managed LSP servers for Lua, JavaScript/TypeScript, Python, Bash,
  JSON, YAML, and Markdown.
- Adds formatters through `conform.nvim`.
- Adds linters through `nvim-lint`.

Install the editor and search helpers with:

```sh
brew install neovim ripgrep fd
```

The system config path is expected to point to this repo:

```sh
~/.config/nvim -> ~/chaotic-thoughts/dotfiles/nvim
```

## Git

The Git configuration lives in `git/gitconfig`.

It configures `git-delta` as the pager for readable side-by-side diffs:

- Shows changed files with decorated headers.
- Shows old and new code side by side.
- Shows line numbers on both sides.
- Keeps moved-line coloring and better merge conflict markers enabled.

Install the diff viewer with:

```sh
brew install git-delta
```

The home config is expected to include this repo config:

```sh
~/.gitconfig includes ~/chaotic-thoughts/dotfiles/git/gitconfig
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
- Initializes Starship for a richer prompt.
- Keeps the local aliases and Node/pnpm path setup.

Install the shell plugins with:

```sh
brew install zsh-autosuggestions zsh-syntax-highlighting fzf starship
```

The home config path is expected to point to this repo:

```sh
~/.zshrc -> ~/chaotic-thoughts/dotfiles/zsh/.zshrc
```
