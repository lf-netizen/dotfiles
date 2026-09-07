# Implementation — 2026-09-07

Historical record of the initial migration. For the maintained setup and current
shortcuts, use [the root README](../../README.md) and
[keyboard issue findings](../keyboard-issues.md). Later session changes include
VS Code preservation, the HTML cheatsheet, navigation/resizing bindings and
Ctrl+Q. This file's verification results describe the initial snapshot only.

Source: `~/dotfiles`. Deployed on macOS. The approved specification is
`~/nameithoweveryouwant/ai-coding-setup-playground/docs/dotfiles-rebuild-plan.md`.
Accepted decisions are recorded there as decisions 031–037; 029 and 030 are
marked superseded. Windows/WSL, package manifests and editor redesign are deferred.

## Applied

- Fresh zsh with direct Powerlevel10k, native completion, autosuggestions,
  highlighting, fzf, zoxide and `cd=z`; no Oh My Zsh initialization.
- Fresh WezTerm and Herdr configs, the original background and prompt, visible
  Herdr sidebar on startup, native Ctrl+B prefix, direct keys from the README.
- Symlink manifest and preview/apply/export/rollback helper; rewritten settings
  use ordinary copies. Git's actual `ignore` file and bat's custom theme are kept.
- Claude/Codex preservation, current official Herdr integrations, legacy hook
  cleanup and one notification owner. No third-party Herdr plugins are required.
- Reviewed, encrypted Raycast settings export; the existing browser target is Zen.
- Archived old `.config` Git history and working tree; retired its `.git`,
  `.gitignore`, Ghostty, iTerm2, tmux, Agent Deck config, old terminal backups and
  obsolete Herdr cheatsheet. Kept `nvim-workflow` and app-managed runtime state.
- Archived `agent-notify` and `AI Agents.app`; uninstalled terminal-notifier 3.1.0.
  No other packages were removed or broadly upgraded.

## Verification

| Check | Result |
| --- | --- |
| Recovery archive | 14,473 recorded entries; SHA-256 verification, full Git bundle verification, SQLite integrity checks and trial prompt-file restore passed. |
| Preserved files | Neovim tree, Karabiner JSON and `.p10k.zsh` match the pre-change backup. |
| Shell | Real PTY startup rendered the existing prompt; fzf widgets, suggestions/highlighting, `cd=z`, command lookup and PATH deduplication passed. Noninteractive startup is silent. |
| Deployment helper | Preview, spaces in paths, conflict backup, repeat apply, rollback and unrelated-link refusal passed in an isolated test home. |
| Terminal config | Installed Herdr 0.8.2 validation passed; WezTerm parsed exactly four host bindings. Live Herdr config reload returned `applied`, with no diagnostics. |
| Herdr input | Scratch-session Kitty input exercised splits, pane focus, tabs, navigator, sidebar, native prefix help and copy mode. |
| Clipboard | Herdr searched/selectively copied `COPY_ACCEPTANCE` to the macOS clipboard; Ctrl+Shift+V pasted those exact bytes into a disposable WezTerm host. |
| Polish input | OS Option-key events produced exactly `ąćęłńóśźżĄĆĘŁŃÓŚŹŻ` in the live WezTerm capture. Both Option sides are configured to preserve composed characters. |
| Font keys | Ctrl+Cmd+= increased host cell dimensions; minus/reset returned the original 1360×888 pixel grid at 80×24 cells. |
| Persistence | `PERSISTENCE_AFTER_DETACH_OK` appeared after the test client detached; the scratch job survived. |
| Agents | Fresh Codex and Claude sessions each returned `DOTFILES_INTEGRATION_OK` without tools and reported native session IDs through the retained hooks. Claude's existing status line rendered. |
| Agent restore | Restarted only the scratch server; both agents resumed the same native session IDs and returned to idle. The default session remained running. |
| Integration repeatability | Both scripts are current v8, with one SessionStart registration per agent. Repeating setup did not duplicate registrations or rewrite unchanged copies. |
| Global app focus | Repeated Alt+J/T/W/I events kept Zen/WezTerm/Obsidian/VS Code frontmost and visible; existing Alt+P/V assignments and FluidVoice Alt+R were verified. |
| Raycast restoration | Controlled import succeeded and reported only Settings (aliases, hotkeys and favorites); private categories were excluded. |
| Cleanup | Old Git metadata and named retired entries are absent from `.config` and recoverable in the private archive. |

Tests used a separate `dotfiles-acceptance-20260907` Herdr session and a temporary
WezTerm host. The active default Herdr server was never stopped. Agent test turns
were no-tools smoke tests; existing authentication and resume data were retained.
An initial pipe-only shell test produced expected terminal/job-control errors;
the real PTY check passed. The first backup attempt exhausted free disk while
duplicating runtime symlink targets; only those newly generated duplicate copies
were removed, then the smaller archive was verified.

Human checks still useful: confirm the image/prompt appearance is to your taste,
exercise Right Option on your physical keyboard, and dictate a short Polish and
English phrase. OS key simulation verifies composition and routing, not hardware
or microphone quality. macOS notice presentation/sound still depends on existing
system notification permissions and Focus settings; no duplicate custom callbacks
remain. These checks do not require another configuration migration.

## Recovery paths

Main archive: `~/.local/state/dotfiles-backups/20260907-195551/`.
`manifest.json` records checksums/modes/links; `config-history.bundle` preserves
all old Git refs; `sqlite/` contains consistent database backups.
`cleanup-manifest.json` maps each retired path to its retained copy.

Slice rollback records are in `~/.local/state/dotfiles-backups/deploy-*/deployment.json`.
Use the README's rollback command for an unchanged deployment, or restore only
the affected files manually after reviewing the record. Avoid replacing live
agent histories, databases or newly written shell history with an older snapshot.

Raycast export password: `raycast-export-password.txt` inside the main archive.
The source checkout has no remote and has not been published.
