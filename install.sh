#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(
  zsh
  tmux
  wezterm
  starship
  git
  nvim
)

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU Stow is required. Install it with: brew install stow" >&2
  exit 1
fi

mkdir -p "$HOME/.config"

remove_repo_symlink() {
  local target="$1"
  local link_target

  if [ ! -L "$target" ]; then
    return
  fi

  link_target="$(readlink "$target")"
  case "$link_target" in
    "$DOTFILES_DIR"/*)
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

cd "$DOTFILES_DIR"
stow --target="$HOME" --restow "${PACKAGES[@]}"

echo "Linked dotfiles with stow."
