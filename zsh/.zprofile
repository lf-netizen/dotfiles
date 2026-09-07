# macOS path_helper runs before this file; put user tools first again.
if [[ -x /opt/homebrew/bin/brew && -z ${HOMEBREW_PREFIX:-} ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.deno/bin" /opt/homebrew/bin /opt/homebrew/sbin $path)
