# Personal dotfiles

macOS: Raycast → WezTerm → Herdr → zsh, with the existing Powerlevel10k,
Neovim, Karabiner, Claude Code and Codex setups.

This checkout (`~/dotfiles`) is the source. `~/.config` contains deployed links
and application-owned runtime data; it is not another dotfiles repository.

## What's maintained

| Directory | Purpose |
| --- | --- |
| `zsh`, `wezterm`, `herdr` | Shell, terminal host, and persistent workspace controls |
| `nvim`, `vscode` | Current editors; VS Code shares Neovim's VS Code-specific branch |
| `karabiner`, `raycast` | Modifier remaps and exported global shortcuts |
| `agents` | Claude/Codex authored settings, instructions, and restore helpers' inventory |
| `bat`, `git`, `img` | Active theme, ignore rules, and terminal background |
| `scripts` | Deployment, export/rollback, and integration/extension setup |
| `docs` | Known issues and historical migration records |

`symlinks.conf` is the deployment manifest. Neovim imports both `plugins/core`
and `plugins/addons`; those files are active even without individual `require`
statements. Old tmux, iTerm2, Agent Deck, and Ghostty configs live only in the
private recovery archive.

Neovim is an ordinary tracked directory, **not a submodule**. Cloning needs no
`--recursive` flag. Deployment symlinks `~/.config/nvim` to it; lazy.nvim installs
editor plugins separately on first launch.

## Daily keys

Open the searchable, offline [HTML keyboard reference](cheatsheet.html) with
`cheatsheet` in a fresh zsh shell. You can also bookmark the page in your browser.
It includes daily and expanded views, app filters, and Print / PDF. Search always
includes the expanded entries. Print uses the current view and filters.

Alt controls global navigation. Plain Ctrl belongs to the focused terminal
application, except Herdr's shipped Ctrl+B prefix. Ctrl+Shift owns Herdr's
daily controls and clipboard paste. Ctrl+Cmd owns occasional font adjustments.
The intentional Karabiner Cmd/Ctrl swap is unchanged.

| Keys | Action |
| --- | --- |
| Alt+Space / Alt+Tab | Raycast / AltTab window cycling |
| Alt+J / T / W / I | Zen / WezTerm / Obsidian / VS Code |
| Alt+P / V / R | Window search / clipboard history / FluidVoice |
| Ctrl+Shift+arrows | Focus Herdr pane |
| Ctrl+Shift+Alt+arrows | Resize Herdr pane |
| Ctrl+Shift+D / E | Split right / down |
| Ctrl+Shift+T / U / I | New / previous / next tab |
| Ctrl+Shift+N | Name and create a workspace |
| Ctrl+Shift+H / L | Previous / next workspace |
| Ctrl+Shift+K / J | Previous / next agent |
| Ctrl+Cmd+1–9 | Jump to workspace 1–9 |
| Ctrl+Shift+1–9 | Agent jump binding; affected by the known WezTerm input bug |
| Ctrl+Shift+Tab | Return to the last pane |
| Ctrl+Shift+W | Close the focused pane immediately |
| Ctrl+Q | Quit WezTerm with confirmation |
| Ctrl+Shift+P / S / Z | Navigator / sidebar / zoom |
| Ctrl+Shift+C / V | Herdr copy mode / WezTerm paste |
| Ctrl+Cmd+= / - / 0 | Increase / decrease / reset font |
| Ctrl+B, then ? | Herdr's native help and fallback bindings |

Copy mode: `/` searches, `n` repeats, h/j/k/l moves, v starts a selection,
y copies, Esc clears/exits. U/I is the usable tab binding in WezTerm; native
Ctrl+Shift+[ / ] remains configured but affected by its input bug.
Ctrl+Shift+- is free. See [keyboard findings](docs/keyboard-issues.md).
Reserve Alt+A/C/E/L/N/O/S/X/Z and shifted variants for Polish letters.

Herdr close confirmations are disabled, including prefix close actions.
Close a tab with Ctrl+B, then Shift+X. Last pane is a back-and-forth pane switch,
not a separate workspace-history command. Ctrl+Cmd also selects numbered workspaces.

zsh uses Emacs editing, Tab completion, inline suggestions (Right accepts),
syntax highlighting, Ctrl+R history, Ctrl+T paths, `cd` → zoxide, `zi` picker,
`builtin cd` for literal paths, `v` → nvim and `lg` → lazygit.
Machine-specific PATH entries live in the untracked `~/.zshrc.local`.
`ls` restores the previous eza layout: icons, colours, Git status and compact
rows, excluding `__pycache__`. `ls -a` includes hidden entries; `command ls`
bypasses the alias. `ll` retains the system's detailed listing with hidden files.

## Deploy and maintain

Currently supported: **Apple Silicon macOS**, with Homebrew at `/opt/homebrew`.
Windows/WSL is planned but is not configured or tested by this release.
Install the prerequisites listed below first, then:

```sh
git clone https://github.com/lf-netizen/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

```sh
./scripts/symlinks.sh preview
./scripts/symlinks.sh apply --slice shell
./scripts/symlinks.sh apply --slice terminal
./scripts/symlinks.sh apply --slice preserved
./scripts/symlinks.sh apply --slice agents
./scripts/setup-agent-integrations.sh
./scripts/setup-vscode.sh
```

Run from any working directory. The manifest uses `mode|slice|source|destination`,
with source relative to this checkout and destination relative to your home.
Conflicts move into private timestamped backups. Unrelated symlinks are refused.
Repeating an unchanged deployment leaves live files alone.

Karabiner JSON and agent settings are ordinary copies because their applications
rewrite them. After changing settings, review them and capture them back:

```sh
./scripts/symlinks.sh export --slice agents
./scripts/symlinks.sh export --slice preserved
git diff
```

Export before applying an older repository copy. Do not run deployment while an
agent or GUI settings editor is saving the same file. Agent exports normalize
home paths and omit Codex project/hook trust; deployment preserves existing local
trust records. Review credentials and other personal settings before committing:
this normalization is not a general secret scrubber. Review hook trust normally
on each machine. Origin is `https://github.com/lf-netizen/dotfiles` (SSH for pushing).

Install Git, Powerlevel10k, fzf, zoxide, eza, Herdr, WezTerm, Neovim, LazyGit,
LazySQL, bat, jq, Node.js/npm (for the Playwright MCP), Python 3.11+, Claude Code
and Codex. Install JetBrains Mono and MesloLGS NF fonts. zsh-autosuggestions and zsh-syntax-highlighting
are sourced directly from Homebrew. There is no package manifest or bulk installer.
See [agent preservation](agents/README.md) and [Raycast settings](raycast/README.md).
The [VS Code companion editor](vscode/README.md) has preserved settings and
shortcuts, Neovim integration, and an installer for its essential extensions.
Use `./scripts/symlinks.sh export --slice vscode` to capture later editor changes.

Install Raycast, Karabiner-Elements, AltTab, Rectangle, Zen, Obsidian and FluidVoice
to reproduce the global workflow; install VS Code before its setup script.
Raycast import requires the separately held export password. Log into coding
agents separately; reinstall their plugins as described in `agents/README.md`.
Run `bat cache --build` after deploying its theme. Open Neovim once to let lazy.nvim
install the locked plugins. Review `:checkhealth` for language tools you use.

Release checks: `python3 scripts/test_deploy.py`, `zsh -n zsh/.zshrc`,
`herdr config check`, and `wezterm show-keys --lua`. The known WezTerm numbered-key
and bracket issues remain documented; this release does not claim to fix them.

## Recovery

The verified pre-rebuild snapshot is:

`~/.local/state/dotfiles-backups/20260907-195551/`

It includes the original `.config` tree and Git history bundle, private agent
state, consistent SQLite snapshots, old shell files, link metadata and checksums.
Retired notifier components are recoverable under `retired/` there.
The full encrypted Raycast export and its password file stay in that private
directory. Never commit that directory or copy older agent databases over live state.

Each applied slice prints its own deployment record. To undo an unchanged slice:

```sh
./scripts/symlinks.sh rollback --record /absolute/path/to/deployment.json
```

Rollback refuses targets edited since deployment. For manual recovery, use an
existing shell or Terminal.app with `/bin/zsh -f`, inspect the record, and restore
only the affected config from its backup. Keep newly written shell history and
agent sessions. Reload Herdr with `herdr server reload-config`; do not stop the
live server to roll back configuration.

See the [initial migration record](docs/history/initial-migration.md) for the
original acceptance tests and recovery history.
