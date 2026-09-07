# Silent environment shared by login and non-login shells.
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.deno/bin" /opt/homebrew/bin /opt/homebrew/sbin $path)
export EDITOR=nvim VISUAL=nvim
