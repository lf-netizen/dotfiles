# VS Code as a companion editor

Preserves the existing default-profile settings and keybindings, including the
intentional Ctrl-based app shortcuts, relative line numbers, Kanagawa, format on
save, Python/Jupyter settings, and Harpoon. No new keybindings are introduced.

Vim editing uses **asvetliakov.vscode-neovim**, backed by the repository's existing
`nvim/init.lua` and its `vim.g.vscode` branch in `nvim/lua/vsc.lua`. VSCodeVim is
explicitly disabled in these settings so two Vim engines do not compete. The
Neovim executable is discovered as `nvim` on PATH, without a username or CPU-specific
Homebrew path. Keep Neovim and the existing JetBrains Mono / MesloLGS NF fonts
installed. On first use, the existing Neovim bootstrap may download its plugins.

## Restore on another Mac

Install VS Code, Neovim, Git, and Python 3.11+ first. From the cloned repository:

```sh
./scripts/symlinks.sh apply --slice preserved
./scripts/setup-vscode.sh
```

The first command deploys the existing Neovim configuration along with the other
preserved configs. The second installs missing extensions from `extensions.txt`
and deploys VS Code settings and keybindings. It also finds VS Code under
`/Applications` if the `code` shell command has not been installed yet.
Reload VS Code, use the **Default** profile, and open a text file to use Vim editing.
Existing named profiles are independent and are not overwritten.

The extension list covers the current Vim, theme, formatting, Python/notebook,
and Harpoon dependencies. Dependencies installed by VS Code may add more entries.
Installed extensions are left at their existing versions; a fresh machine gets
the marketplace version compatible with its VS Code. This is not a version lock.
[The historical inventory](../docs/history/vscode-extensions-inventory.txt) records the original complete list for optional manual
restoration, including older AI, remote, and visual-effect extensions; setup does
not install that larger list or remove anything already installed.

Existing chat shortcuts remain in the keybindings file, but their availability
depends on installed chat integrations and sign-in. Legacy Alt+J/K bindings can
be intercepted by global shortcuts. This capture preserves them as requested.

## Capture edits

VS Code owns regular files in `~/Library/Application Support/Code/User/`:

```sh
./scripts/symlinks.sh preview --slice vscode
./scripts/symlinks.sh export --slice vscode
git diff -- vscode
```

Export after editing settings or shortcuts, before applying an older repository
copy. Settings Sync can also change these files; review/export its changes before
reapplying. Deployment backs up replaced files using the existing private backup
and rollback mechanism. Settings JSON permits comments (JSONC).

Only settings, keybindings and extension IDs are captured. There are currently no
user snippets. Accounts, tokens, workspace history, extension databases, named
profiles and app binaries are machine-local. No package manager manifest is added.

References: [VS Code CLI extension installation](https://code.visualstudio.com/docs/configure/command-line),
[Neovim integration and conflicting Vim extensions](https://github.com/vscode-neovim/vscode-neovim).
