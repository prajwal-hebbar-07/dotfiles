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
remove_repo_symlink "$HOME/.claude-one"
remove_repo_symlink "$HOME/.claude-one/settings.json"
remove_repo_symlink "$HOME/.claude-one/skills"
remove_repo_symlink "$HOME/.claude-one/statusline.sh"
remove_repo_symlink "$HOME/.claude-two"
remove_repo_symlink "$HOME/.claude-two/settings.json"
remove_repo_symlink "$HOME/.claude-two/skills"
remove_repo_symlink "$HOME/.claude-two/statusline.sh"

cd "$DOTFILES_DIR"
stow --target="$HOME" --restow "${PACKAGES[@]}"

# claude-one/claude-two are separate logins (different CLAUDE_CONFIG_DIR) that
# share one settings file. They write sessions, caches, and credentials into
# these real directories, so keep them real and symlink only the shared,
# login-agnostic settings.json into each.
mkdir -p "$HOME/.claude-one" "$HOME/.claude-two"
ln -sfn "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude-one/settings.json"
ln -sfn "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude-two/settings.json"

echo "Linked dotfiles with stow."
