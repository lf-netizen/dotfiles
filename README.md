# Personal dotfiles

macOS: Raycast → WezTerm or Ghostty → Herdr → zsh, with the existing
Powerlevel10k, Neovim, Karabiner, Claude Code and Codex setups.

This checkout (`~/dotfiles`) is the source. `~/.config` contains deployed links
and application-owned runtime data; it is not another dotfiles repository.

## What's maintained

| Directory | Purpose |
| --- | --- |
| `zsh`, `wezterm`, `ghostty`, `herdr` | Shell, terminal hosts, and persistent workspace controls |
| `nvim`, `vscode` | Current editors; VS Code shares Neovim's VS Code-specific branch |
| `karabiner`, `raycast` | Modifier remaps and exported global shortcuts |
| `agents` | Claude/Codex/OMP authored settings, instructions, and restore helpers' inventory |
| `bat`, `git`, `img`, `lazygit` | Active theme, ignore rules, terminal background, and Git diff rendering |
| `scripts` | Deployment, export/rollback, and integration/extension setup |
| `docs` | Known issues and historical migration records |

`symlinks.conf` is the deployment manifest. Neovim uses `lua/config` and flat `lua/plugins` specs; see the
[editor guide](nvim/README.md). Old tmux, iTerm2, and Agent Deck configs live only in the private
recovery archive. Ghostty now has a maintained trial configuration.

Neovim is an ordinary tracked directory, **not a submodule**. Cloning needs no
`--recursive` flag. Deployment symlinks `~/.config/nvim` to it; lazy.nvim installs
editor plugins separately on first launch.

## Daily keys

Open the searchable, offline [HTML keyboard reference](docs/cheatsheet.html) with
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
| Ctrl+Shift+arrows or Ctrl+arrows | Focus Neovim split, then Herdr pane at the editor edge |
| Ctrl+Shift+Alt+arrows or H/J/K/L | Resize Neovim split or Herdr pane |
| Ctrl+Shift+backslash / minus | Split Herdr right / below; Ctrl alone splits Neovim |
| Ctrl+Shift+D / E | Additional Herdr split right / below aliases |
| Ctrl+Shift+T | New tab |
| Ctrl+Shift+H / L | Previous / next tab |
| Ctrl+Shift+R | Rename the current tab/task |
| Ctrl+Shift+N | Name and create a workspace |
| Ctrl+Shift+, / . or [ / ] | Previous / next workspace |
| Ctrl+Shift+K / J | Previous / next agent |
| Ctrl+Cmd+1–9 | Jump to workspace 1–9 |
| Ctrl+Shift+1–8 | Jump to agent by number; affected by the known WezTerm input bug |
| Ctrl+Shift+9 | Jump to the last local agent in workspace/tab order |
| Ctrl+Shift+O (letter O) | Jump to the most recently blocked/done local agent |
| Ctrl+Shift+Tab | Return to the last pane (back-and-forth) |
| Ctrl+Shift+W | Close the focused pane immediately |
| Ctrl+Q | Quit the terminal host with confirmation |
| Ctrl+Shift+P / S / Z | Navigator / sidebar / zoom |
| Ctrl+Shift+C / V | Herdr copy mode / terminal host paste |
| Ctrl+Cmd+= / - / 0 | Increase / decrease / reset font |
| Ctrl+B, then ? | Herdr's native help and fallback bindings |

Copy mode: `/` searches, `n` repeats, h/j/k/l moves, v starts a selection,
y copies, Esc clears/exits. Workspace switching uses Ctrl+Shift+comma / period or [ / ];
WezTerm forwards these as explicit Kitty key sequences; Ghostty encodes them natively.
Ctrl+Shift+- splits below. Shared split keys use `herdr/splits.py` to route
to Neovim when it is focused; plain Ctrl+H/J/K/L remain local to each application.
See [keyboard findings](docs/keyboard-issues.md).
Reserve Alt+A/C/E/L/N/O/S/X/Z and shifted variants for Polish letters.

Herdr close confirmations are disabled, including prefix close actions.
Close a tab with Ctrl+B, then Shift+X. Last pane is a back-and-forth pane switch,
not a separate workspace-history command. Ctrl+Shift+6 selects agent 6.
Ctrl+Shift+9 runs
`herdr/focus-last-agent.py` to select the final local agent in workspace/tab order;
it does not follow remote-machine lists or custom filtered agent views.
Ctrl+Shift+O uses the same helper to focus the most recently changed local
agent reported as blocked or done, excluding the currently focused agent.
It does nothing if none qualify; idle/working agents are skipped. Status comes
from the server, so another client's seen/unseen state can differ.
Ctrl+Cmd also selects numbered workspaces.

The agent panel stays in workspace/tab order (`grouped`), not attention order:
done/needs-input indicators change without moving the row. Task/tab names get
a bright, full-width first line, with workspace and agent type underneath.
The expanded sidebar is 38–48 columns. Use Ctrl+Shift+R to name a task.

zsh uses Emacs editing, Tab completion, inline suggestions (Right accepts),
syntax highlighting, Ctrl+R history, Ctrl+T paths, `cd` → zoxide, `zi` picker,
`builtin cd` for literal paths, `v` → nvim and `lg` → lazygit.
Machine-specific PATH entries live in the untracked `~/.zshrc.local`.
LazyGit uses delta for syntax-highlighted diffs with line numbers and red/green
backgrounds. Install it with `brew install git-delta`; `lazygit/config.yml`
is linked to `~/.config/lazygit/config.yml` with the `preserved` slice.
`.zshenv` exports `XDG_CONFIG_HOME="$HOME/.config"` so LazyGit finds it on macOS.
It uses the installed bat Kanagawa theme, aligned with Neovim's Wave palette,
plus Kanagawa diff backgrounds and line-number colors. After editing
`bat/themes/kanagawa.tmTheme`, run `bat cache --build`. The syntax engines differ,
so individual token colors may still vary between delta and Neovim. This setup
keeps the default panel arrangement and keys, shows per-file change counts,
and shrinks side panels to fit their contents. Ctrl+U/D scroll 15 lines
(a fixed approximation of half a page); this shared setting also affects
PgUp/PgDn, Shift+J/K, and mouse-wheel scrolling. Restart `lg` after edits.
Press `|` to switch between delta (the default) and word-level diffs for prose.
`ls` restores the previous eza layout: icons, colours, Git status and compact
rows, excluding `__pycache__`. `ls -a` includes hidden entries; `command ls`
bypasses the alias. `ll` retains the system's detailed listing with hidden files.

## Ghostty trial

Ghostty 1.3.1+ is configured alongside WezTerm, not in place of it. Launch
**Ghostty** from Raycast or Applications. Alt+T and the encrypted Raycast export
still target WezTerm while evaluating the new host.

Both hosts run `/opt/homebrew/bin/herdr`, attaching to the same default persistent
session. Shells, tabs, panes, workspaces, agents, sidebar, copy mode and notifications
remain Herdr-owned; no second set of terminal tabs or split shortcuts is added.
Quit closes the terminal client, not Herdr's persistent jobs.

`ghostty/config.ghostty` uses Ghostty's bundled **Kanagawa Wave** theme, including
its palette, background, cursor and selection colors. The 14 pt JetBrains Mono
font and fallback order, disabled ligatures, default non-blinking block cursor,
zero padding, hidden titlebar, centered cover wallpaper, paste/font/quit shortcuts
and close confirmation still match WezTerm. Both Option keys retain Polish
composition. Karabiner's Cmd/Ctrl swap includes Ghostty on both sides.

Ghostty has no WezTerm-style per-image HSB transform. Its tracked wallpaper is
preprocessed from the original with saturation zero and brightness halved in
linear RGB; Ghostty mixes it 50/50 with the theme background (`#1f1f28` for
Kanagawa Wave) without desktop transparency.
Regenerate it after changing the original (ImageMagick is needed for this and Neovim image previews):

```sh
magick img/background.jpeg -colorspace RGB -fx 'max(r,max(g,b))*0.5' \
  -colorspace sRGB -quality 95 img/ghostty-background.jpeg
```

Font rasterization and image blending can differ between renderers; pixel-identical
appearance is not guaranteed. Ghostty uses display-synchronized rendering rather
than WezTerm's configured 60 FPS cap. Its cursor setting is a default that terminal
applications can override. macOS screen-capture permissions prevented a visual
side-by-side check; native input and Herdr interaction checks passed.
See [keyboard verification](docs/keyboard-issues.md#ghostty-131-trial).

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

Install Git, Powerlevel10k, fzf, zoxide, eza, Herdr, WezTerm, Ghostty 1.3.1+,
Neovim, LazyGit, git-delta, LazySQL, bat, jq, Node.js/npm (for the Playwright MCP), Python 3.11+,
Claude Code and Codex. Install JetBrains Mono and MesloLGS NF fonts. zsh-autosuggestions and zsh-syntax-highlighting
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
`python3 scripts/test_splits.py`, `herdr config check`, `wezterm show-keys --lua`, and
`/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config`.
The known WezTerm numbered-key and bracket issues remain documented; Ghostty
uses native Kitty encoding rather than carrying those workarounds over.

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
