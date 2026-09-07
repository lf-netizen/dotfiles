# Preserve the existing Powerlevel10k instant prompt and prompt settings.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
typeset -U path PATH fpath FPATH
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_SAVE_NO_DUPS HIST_REDUCE_BLANKS INC_APPEND_HISTORY
unsetopt SHARE_HISTORY
autoload -Uz compinit
compinit
zmodload zsh/complist
zstyle ':completion:*' menu select
bindkey -e
bindkey '^U' kill-whole-line

if (( $+commands[fzf] )); then
  export FZF_ALT_C_COMMAND=''
  eval "$(fzf --zsh)"
fi
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
  alias cd=z
fi
alias v=nvim
alias lg=lazygit
if (( $+commands[eza] )); then
  alias ls="eza --color=always --git --icons=always --long --no-filesize --no-time --no-user --no-permissions -I '__pycache__'"
fi
alias ll='command ls -lah'
# Resolve through the live zshrc symlink so this also works after moving the repo.
function cheatsheet() {
  local dotfiles_root="${${:-${(%):-%x}}:A:h:h}"
  open "$dotfiles_root/cheatsheet.html"
}
export BAT_THEME=kanagawa
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
[[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]] && source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ -r "${ZDOTDIR:-$HOME}/.p10k.zsh" ]] && source "${ZDOTDIR:-$HOME}/.p10k.zsh"
# Must follow other widget definitions.
[[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
