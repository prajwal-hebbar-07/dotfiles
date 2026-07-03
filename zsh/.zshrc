# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt inc_append_history
setopt share_history

# Completion
autoload -Uz compinit
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:descriptions' format '%F{magenta}%d%f'
zstyle ':completion:*:messages' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for: %d%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
compinit

setopt auto_list
setopt auto_menu
setopt auto_param_slash
setopt complete_in_word
setopt always_to_end

# Keys
bindkey -e
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# Colors
autoload -Uz colors
colors
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad

# Plugins
if command -v brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix)}"
fi

if [[ -o interactive && -t 0 ]] && command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="
    --height=45%
    --layout=reverse
    --border=rounded
    --info=inline
    --prompt='search > '
    --pointer='>'
    --marker='*'
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#a6e3a1,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --color=border:#89b4fa
  "

  export FZF_CTRL_R_OPTS="
    --prompt='history > '
    --preview='echo {}'
    --preview-window=down:3:wrap
    --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
    --header='Enter: use command | Ctrl-y: copy command'
  "

  if [ -n "$HOMEBREW_PREFIX" ] && [ -x "$HOMEBREW_PREFIX/opt/fzf/bin/fzf-preview.sh" ]; then
    export FZF_CTRL_T_OPTS="
      --prompt='files > '
      --preview='$HOMEBREW_PREFIX/opt/fzf/bin/fzf-preview.sh {}'
      --preview-window=right:60%:wrap
    "
  else
    export FZF_CTRL_T_OPTS="--prompt='files > '"
  fi

  export FZF_ALT_C_OPTS="
    --prompt='folders > '
    --preview='ls -la {} 2>/dev/null | sed -n \"1,80p\"'
    --preview-window=right:60%:wrap
  "

  if [ -n "$HOMEBREW_PREFIX" ]; then
    [ -r "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh" ] && source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
    [ -r "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ] && source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  fi
fi

if [ -n "$HOMEBREW_PREFIX" ]; then
  if [ -r "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi
fi

# Aliases
alias gn='codex --dangerously-bypass-approvals-and-sandbox'
alias gc='codex resume --last --dangerously-bypass-approvals-and-sandbox'
alias g='lazygit'
alias cn='claude --dangerously-skip-permissions'
alias cc='claude --continue --dangerously-skip-permissions'

# Node
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

export PATH="$HOME/.local/bin:$PATH"

# Prompt
export STARSHIP_CONFIG="$HOME/chaotic-thoughts/dotfiles/starship/starship.toml"
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Syntax highlighting should be loaded last.
if [ -n "$HOMEBREW_PREFIX" ]; then
  if [ -r "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
fi
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


# Added by Antigravity CLI installer
export PATH="/Users/hebbar/.local/bin:$PATH"
