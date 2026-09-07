# Agent preservation

The live agent homes remain `~/.claude` and `~/.codex`. Authentication,
sessions, histories, SQLite databases, downloaded plugins and runtime-provided
skills stay there. Their private backup is outside this repository.

Claude settings, instructions, the existing jq status line, enabled plugins and
the personal graphify skill are preserved. Codex retains its model, effort,
permissions, MCP settings, rules and TUI status line. Instructions remain separate.

`installation-inventory.json` records the installed plugin identities and Claude
versions/source. Codex's curated remote packages currently are openai-templates
0.1.1, plugin-management 0.1.0 and deep-research-work 0.1.14. These are runtime
managed; reconnect/reinstall through Codex's plugin UI on a new machine. Do not
copy downloaded caches into authored sources. The `.system` and
`codex-primary-runtime` skills also belong to the supplied runtime.

Claude's marketplace is `anthropics/claude-plugins-official`; the preserved
enabled entries are frontend-design, code-simplifier and context7. The inventory
records their versions. Reinstall from that marketplace when restoring on a new
machine, then verify availability in Claude's plugin UI.

## Herdr integrations

Run `../scripts/setup-agent-integrations.sh` after deploying settings. It checks
both registrations and current integration versions, installs missing/outdated
ones using `herdr integration install claude` / `codex`, and exports the resulting
settings back into the checkout. It does not install third-party plugins.

Both official integrations are v8 with Herdr 0.8.2. Their generated scripts stay
at their original agent-owned paths. They require `python3` and report native
session identity. Herdr detects agent state and delivers system notifications.
Codex reports its session identity after its first submitted turn. Scratch
sessions launched from inside Codex should not inherit another `CODEX_THREAD_ID`.

The old Agent Deck and agent-notify callbacks are removed. Claude uses
`preferredNotifChannel = notifications_disabled` and disabled mobile push
channels; Codex uses `tui.notifications = false` while keeping hooks enabled.
The existing Claude status line is preserved. There is no outside-Herdr notifier.

Configuration files copied by the agents must be re-exported after deliberate
changes. Herdr installer output must be captured before any baseline reapply.
`scripts/portable.py` normalizes exported hook/status-line home paths to `$HOME`
and omits Codex project trust and hook approval records. Deployment retains the
destination's existing trust records; a fresh machine must approve hooks normally.
It does not strip arbitrary secrets: review exports before committing them.

References: [Herdr integrations](https://herdr.dev/docs/integrations/),
[Claude settings reference](https://code.claude.com/docs/en/settings-reference#preferrednotifchannel),
[Codex config reference](https://learn.chatgpt.com/docs/config-file/config-reference).
