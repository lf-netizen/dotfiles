#!/bin/sh
# Restore the default macOS profile; install only missing extensions.
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(dirname -- "$script_dir")
if [ "$(uname -s)" != Darwin ]; then
  echo 'This setup currently targets macOS.' >&2
  exit 1
fi
if command -v code >/dev/null 2>&1; then
  code_cli=$(command -v code)
else
  code_cli='/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
fi
if [ ! -x "$code_cli" ]; then
  echo 'Install Visual Studio Code first (and its code shell command).' >&2
  exit 1
fi
if ! command -v nvim >/dev/null 2>&1; then
  echo 'Install Neovim first; VS Code uses the existing Neovim configuration.' >&2
  exit 1
fi
python3 - "$repo_dir" <<'PY'
from pathlib import Path
import sys
repo = Path(sys.argv[1])
target = Path.home() / '.config/nvim'
if target.resolve() != (repo / 'nvim').resolve():
    sys.exit('Deploy the shared Neovim config first: ./scripts/symlinks.sh apply --slice preserved')
PY
installed=$("$code_cli" --list-extensions)
while IFS= read -r extension || [ -n "$extension" ]; do
  case "$extension" in ''|'#'*) continue ;; esac
  if printf '%s\n' "$installed" | /usr/bin/grep -Fxiq -- "$extension"; then
    printf 'OK: %s\n' "$extension"
  else
    "$code_cli" --install-extension "$extension"
  fi
done < "$repo_dir/vscode/extensions.txt"
"$script_dir/symlinks.sh" apply --slice vscode
printf '\nVS Code default profile restored. Reload the editor to load changed settings.\n'
