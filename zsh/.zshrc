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

# Homebrew and GNU tools
typeset -U path PATH

if command -v brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix)}"
fi

if [ -n "$HOMEBREW_PREFIX" ]; then
  path=("$HOMEBREW_PREFIX/bin" $path)

  if [ -d "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin" ]; then
    path=("$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin" $path)
  fi
fi

if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
elif command -v gdircolors >/dev/null 2>&1; then
  eval "$(gdircolors -b)"
fi

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

if [[ -o interactive && -t 0 ]] && command -v fzf >/dev/null 2>&1; then
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type=d --hidden --strip-cwd-prefix --exclude .git'
  fi

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

  export FZF_CTRL_T_OPTS="
    --prompt='files > '
    --preview='bat --style=numbers --color=always --line-range=:300 {} 2>/dev/null || eza --tree --level=2 --icons=always --color=always {} 2>/dev/null'
    --preview-window=right:60%:wrap
  "

  export FZF_ALT_C_OPTS="
    --prompt='folders > '
    --preview='eza --tree --level=2 --icons=always --color=always --group-directories-first {} 2>/dev/null'
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
alias c='code'
alias ca='cursor-app'
alias cc1='CLAUDE_CONFIG_DIR="$HOME/.claude-one" claude --dangerously-skip-permissions'
alias cc2='CLAUDE_CONFIG_DIR="$HOME/.claude-two" claude --dangerously-skip-permissions'
alias g='lazygit'
alias hd='hunk diff'
alias ls='eza --long --icons=always --git --no-user --group-directories-first'
alias ll='eza --long --icons=always --git --no-user --group-directories-first'
alias la='eza --long --all --icons=always --git --no-user --group-directories-first'
alias lt='eza --tree --level=3 --icons=always --git --group-directories-first'
alias tree='tree -L 3 -a -I ".git|node_modules|.venv|__pycache__" --charset X'
alias rgi='rg --hidden --glob "!.git"'
alias rgf='rg --files --hidden --glob "!.git"'
alias yy='yazi'
alias herdr-stop-all='herdr session list --json | jq -r ".[].name" | while read -r s; do herdr session stop "$s"; done'

sesh-pick() {
  if ! command -v sesh >/dev/null 2>&1; then
    echo "sesh is not installed" >&2
    return 1
  fi

  local session
  if command -v gum >/dev/null 2>&1; then
    session="$(sesh list -t -c | gum filter --height 20 --placeholder 'Pick session')"
  else
    session="$(sesh list -t -c | fzf --height 45% --border --prompt='session > ')"
  fi

  [ -n "$session" ] && sesh connect "$session"
}

alias ss='sesh-pick'

cursor-app() {
  local claude_config_dir="$HOME/.claude-cursor"
  mkdir -p "$claude_config_dir"
  open --env "CLAUDE_CONFIG_DIR=$claude_config_dir" -a "Cursor" "$@"
}

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
if [[ -o interactive && -t 1 && "${HERDR_ENV:-}" = "1" && -z "${HERDR_PROMPT_TOP_PADDED:-}" ]]; then
  printf '\n'
  export HERDR_PROMPT_TOP_PADDED=1
fi

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
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

# Added by Devin
export PATH="/Users/hebbar/.codeium/windsurf/bin:$PATH"

# Added by Antigravity IDE
export PATH="/Users/hebbar/.antigravity-ide/antigravity-ide/bin:$PATH"
