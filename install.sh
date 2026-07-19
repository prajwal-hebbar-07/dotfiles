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
  helix
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
remove_repo_symlink "$HOME/.config/helix"
remove_repo_symlink "$HOME/.config/git/config"
remove_repo_symlink "$HOME/.claude/skills"
remove_repo_symlink "$HOME/.claude-one"
remove_repo_symlink "$HOME/.claude-one/settings.json"
remove_repo_symlink "$HOME/.claude-one/skills"
remove_repo_symlink "$HOME/.claude-one/statusline.sh"
remove_repo_symlink "$HOME/.claude-two"
remove_repo_symlink "$HOME/.claude-two/settings.json"
remove_repo_symlink "$HOME/.claude-two/skills"
remove_repo_symlink "$HOME/.claude-two/statusline.sh"
# Clean up per-skill symlinks, including retired ones, so re-running install on
# a machine that had the old skills replaces them with the current set.
for _skill in commit ship plan plan-review plan-ask plan-detail plan-done \
  project-steps step-plan; do
  remove_repo_symlink "$HOME/.codex/skills/$_skill"
done

# Codex keeps runtime state alongside its skills, so preserve its real config
# directory and let stow symlink only the tracked skills into it.
mkdir -p "$HOME/.codex/skills"

cd "$DOTFILES_DIR"
stow --target="$HOME" --restow "${PACKAGES[@]}"

# The default Claude config and the claude-one/claude-two logins (each a
# separate CLAUDE_CONFIG_DIR) all share one repo-tracked skills folder. Each
# config dir keeps its own sessions, caches, and credentials as a real
# directory, so symlink only the shared skills/ folder into it.
for _claude_dir in "$HOME/.claude" "$HOME/.claude-one" "$HOME/.claude-two"; do
  mkdir -p "$_claude_dir"
  # ln -sfn would nest inside a pre-existing real skills dir; drop it first.
  [ -d "$_claude_dir/skills" ] && [ ! -L "$_claude_dir/skills" ] \
    && rmdir "$_claude_dir/skills" 2>/dev/null
  ln -sfn "$DOTFILES_DIR/claude/skills" "$_claude_dir/skills"
done

# claude-one/claude-two additionally share one login-agnostic settings.json.
ln -sfn "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude-one/settings.json"
ln -sfn "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude-two/settings.json"

echo "Linked dotfiles with stow."
