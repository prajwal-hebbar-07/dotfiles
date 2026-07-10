#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEGACY_DOTFILES_DIR="$HOME/chaotic-thoughts/dotfiles"
PACKAGES=(
  zsh
  tmux
  wezterm
  starship
  git
  nvim
  herdr
  claude-one
  claude-two
  codex
)

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU Stow is required. Install it with: brew install stow" >&2
  exit 1
fi

mkdir -p "$HOME/.config"

remove_repo_symlink() {
  local target="$1"
  local link_target
  local resolved_target
  local resolved_dir

  if [ ! -L "$target" ]; then
    return
  fi

  link_target="$(readlink "$target")"
  case "$link_target" in
    /*)
      resolved_target="$link_target"
      ;;
    *)
      resolved_target=""
      if resolved_dir="$(
        cd "$(dirname "$target")"
        cd "$(dirname "$link_target")" 2>/dev/null
        pwd -P
      )"; then
        resolved_target="$resolved_dir/$(basename "$link_target")"
      fi
      ;;
  esac

  case "$link_target" in
    "$DOTFILES_DIR"/*)
      rm "$target"
      return
      ;;
    "$LEGACY_DOTFILES_DIR"/* | *"chaotic-thoughts/dotfiles"/*)
      rm "$target"
      return
      ;;
  esac

  case "$resolved_target" in
    "$DOTFILES_DIR"/* | "$LEGACY_DOTFILES_DIR"/*)
      rm "$target"
      ;;
  esac
}

remove_repo_symlink "$HOME/.zshrc"
remove_repo_symlink "$HOME/.config/tmux"
remove_repo_symlink "$HOME/.config/wezterm"
remove_repo_symlink "$HOME/.config/starship"
remove_repo_symlink "$HOME/.config/starship.toml"
remove_repo_symlink "$HOME/.config/nvim"
remove_repo_symlink "$HOME/.config/git/config"
remove_repo_symlink "$HOME/.config/herdr"
remove_repo_symlink "$HOME/.config/herdr/bin"
remove_repo_symlink "$HOME/.config/herdr/config.toml"
remove_repo_symlink "$HOME/.claude-one"
remove_repo_symlink "$HOME/.claude-one/settings.json"
remove_repo_symlink "$HOME/.claude-one/skills"
remove_repo_symlink "$HOME/.claude-one/statusline.sh"
remove_repo_symlink "$HOME/.claude-two"
remove_repo_symlink "$HOME/.claude-two/settings.json"
remove_repo_symlink "$HOME/.claude-two/skills"
remove_repo_symlink "$HOME/.claude-two/statusline.sh"
remove_repo_symlink "$HOME/.codex/skills"
remove_repo_symlink "$HOME/.codex/skills/ship"

# Herdr writes logs and sockets next to config.toml, so keep this as a real
# directory and symlink only the config file into it.
mkdir -p "$HOME/.config/herdr"

# claude-one/claude-two write sessions, caches, and credentials alongside their
# statusline.sh and settings.json, so keep them as real directories and
# symlink only the tracked config files into them.
mkdir -p "$HOME/.claude-one" "$HOME/.claude-two"

# Codex keeps runtime state alongside its skills, so preserve its real config
# directories and symlink only the tracked skill into them.
mkdir -p "$HOME/.codex/skills"

cd "$DOTFILES_DIR"
stow --target="$HOME" --restow "${PACKAGES[@]}"

echo "Linked dotfiles with stow."
