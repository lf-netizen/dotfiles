# macOS modified-number and punctuation input

Installed WezTerm: nightly `20260906-101927-d2f3f05b`. Ghostty 1.3.1 is now
configured as an alternative macOS host for the same Herdr workflow. WezTerm
remains installed for fallback and future Windows use. The findings below
retain the stable/nightly distinction from the original tests.

Reproduced 2026-09-07 with installed WezTerm
`20240203-110809-5046fc22` and the official nightly
`20260906-101927-d2f3f05b`. Herdr is 0.8.2.

## Current bindings (2026-09-18)

### Shared editor/pane controls (2026-09-19)

Ctrl+arrows navigate Neovim windows or Herdr panes. Ctrl+Shift+Alt+arrows
(and H/J/K/L aliases) resize both. `herdr/splits.py` queries the foreground
process and forwards the arrow chord to Neovim, or operates on the explicit
Herdr pane. Plain Ctrl+H/J/K/L remain application-local. Ctrl+backslash/minus
split Neovim right/below; adding Shift splits Herdr right/below.

Current smart-splits master includes a native Herdr backend. Its resize
amount is converted from integer editor steps to Herdr fractions: 3 becomes
0.03, avoiding Herdr's 0.5 clamp. An isolated Herdr session verified editor
focus, crossing the editor edge, editor resizing and a 3% outer-pane resize.
Routing regression tests cover all directions and failed process detection.

No enabled macOS symbolic hotkeys use arrows in the inspected preferences.
Raycast's live mappings are encrypted, so physical-key collisions with its
custom window-management shortcuts remain unverified. Ghostty font bindings
are unchanged; the user reports that they do not work with physical input,
despite the older synthetic-event results below.

Herdr accepts both Ctrl+Shift+comma/period and Ctrl+Shift+[/] for workspaces.
WezTerm explicitly sends Kitty sequences for all four keys, plus Ctrl+Shift+6
(agent 6) and Ctrl+Shift+9 (last local agent).
Ghostty uses its native encoding. Agent-number bindings remain on 1–8;
the historical WezTerm number-key issue still applies to those keys.

The last-agent helper follows local workspace/tab order (`agent_panel_sort =
"spaces"`), not remote-machine lists or custom filtered agent views. The
last-pane action can return within the same tab after switching panes.

Config validation passed; these new physical shortcuts still need a manual
check in the user's terminal. Earlier captures below describe the old bindings.

## Reproduction and evidence

### Herdr 0.9.1 navigation investigation (2026-09-19)

The active Ghostty client failed Ctrl+Shift+Tab and Ctrl+Shift+9 even after
an in-client reload (Ctrl+B, then Shift+R). An isolated Herdr 0.9.1 PTY test
with the same bindings confirmed `ESC [ 9;6u` switches back to the previous
pane, while `ESC [ 57;6u` and `ESC [ 111;6u` invoke the 9/O custom commands.
That test used marker commands, so it verifies key dispatch, not live agent focus.

Ghostty explicitly forwards `ESC [ 9;6u` for Ctrl+Shift+Tab and
`ESC [ 111;6u` for Ctrl+Shift+O. The user confirmed both still need these
encoding rules. Ctrl+Shift+9 works with native encoding after the helper fix
below, so its temporary forwarding rule was removed. The original physical
bytes were not captured, so the exact encoding difference is unconfirmed.
Herdr's server reload does not reload Ghostty's own config; use
Ghostty → Reload Configuration.

The separate 9/O failure was traced to the Herdr server's inherited GUI PATH:
`/usr/bin:/bin:/usr/sbin:/sbin:/Applications/Ghostty.app/Contents/MacOS`.
Replaying its `/bin/sh -lc` command lookup found Python but could not find
`herdr`. Detached custom commands discard stderr, hiding the helper failure.
The helper now uses `HERDR_BIN_PATH`, supplied by Herdr, with the repository's
standard `/opt/homebrew/bin/herdr` installation as a fallback. Both agent-list
and agent-focus subprocesses use that executable.

Disk pressure also caused temporary-file and Herdr sound errors during the
investigation; it has not been established as the cause of the shortcut failures.

Use a raw terminal receiver outside Herdr. Request Kitty keyboard flags 7
(`ESC [ > 7 u`), matching Herdr's normal host mode, and send logical Ctrl+Shift
keypresses to the WezTerm GUI. Test events were sent directly to the GUI process
to isolate terminal encoding from the intentional Karabiner swap. Earlier
physical-key captures with modifier 10 were Cmd+Shift and are not evidence of
Ctrl+Shift behavior.

| Key | Stable key-down bytes | Expected meaning |
| --- | --- | --- |
| Ctrl+Shift+1 | literal `1` | Ctrl+Shift+1 |
| Ctrl+Shift+2 | `ESC [ 50:64;6u` | Ctrl+Shift+2 (correct) |
| Ctrl+Shift+3 | literal `3` | Ctrl+Shift+3 |
| Ctrl+Shift+[ | bare Escape | Ctrl+Shift+[ |
| Ctrl+Shift+] | byte 0x1d | Ctrl+Shift+] |

Key-release events retain modifier 6 even when key-down loses it. With flags 31,
the same 1/2/3 test produces key-down events with modifier 6. Full reporting
therefore exposes information still available inside WezTerm. The nightly still
sends literal 1/3 and byte 0x1d; its left bracket produces an encoded Escape with
base-layout key 91. Merely upgrading is not a demonstrated fix.

## Source-level cause

The macOS `key_common` path can clear the processed modifiers when `chars` and
`charactersIgnoringModifiers` differ, retaining them in `RawKeyEvent`.
`encode_kitty` then checks the processed modifiers for its early plain-text
return, before consulting the raw modifiers. This loses modified key-down events
unless full reporting is requested. Control-character recovery accounts for
different behavior of particular keys, including 2.

Source references:

- [macOS input path, installed release](https://github.com/wezterm/wezterm/blob/20240203-110809-5046fc22/window/src/os/macos/window.rs)
- [Kitty encoder, installed release](https://github.com/wezterm/wezterm/blob/20240203-110809-5046fc22/wezterm-input-types/src/lib.rs)
- [Herdr host keyboard setup](https://github.com/herdrdev/herdr/blob/v0.8.2/src/client/mod.rs)

## Status

Confirmed terminal input bug; **not fixed in the installed nightly**. The initial
investigation deployed no translation bindings, custom binaries, reporting-mode
injection, or Karabiner changes. The nightly is now the installed host; the tab-key
workaround below does not fix numbered or bracket keys.

A proper fix needs to preserve raw modifier and key identity in WezTerm's Kitty
encoding, including Ctrl+Shift punctuation, while retaining composed-text input.
Regression coverage should include key-down and key-up for 1–9 and brackets,
flags 7 and 31, and Polish Option-letter composition. Changing the initial
plain-text check alone is insufficient for the bracket key identity issue.

Current usable navigation: Ctrl+Shift+J/K for agents, H/L for tabs,
comma/period or brackets for workspaces, Ctrl+Shift+P navigator, and Ctrl+Cmd+1–9 for workspaces.
Ctrl+Shift+1–9 is still configured for agents but is affected by this bug.

### Comma/period tab navigation workaround

On 2026-09-13, a physical Ctrl+Shift+period event sent directly to an isolated
WezTerm nightly GUI typed into the shell instead of switching Herdr tabs.
The config now intercepts `phys:Comma` and `phys:Period` with `CTRL|SHIFT`,
sending `ESC [ 44;6u` and `ESC [ 46;6u`. These bypass the affected encoder;
Herdr binds them as `ctrl+shift+comma` and `ctrl+shift+period`.

Physical key events then switched next/previous tabs and wrapped correctly
in an isolated Herdr 0.8.2 session. U/I and bracket tab bindings were removed;
the native Ctrl+B then p/n fallbacks remain. This is a two-key workaround,
not a global keyboard-protocol or Polish-input change.

## Escape: separate confirmed interaction

An isolated Herdr 0.8.2 session running a raw input receiver reproduced:

- `ESC` followed immediately by `ESC [ 27;1:3u` (Escape release): no input delivered.
- A lone `ESC`, with an idle gap: one Escape delivered.
- `ESC [ 27;1u` followed by `ESC [ 27;1:3u`: one Escape delivered immediately.

Herdr's macOS host framer preserves doubled Escape sequences. While mouse
capture is active it waits up to 150 ms for a continuation of a bare Escape.
An encoded release arriving in that interval can join the pending press into an
unrecognized sequence. This explains why repeated taps can disappear, while a
longer hold or an overlay using full keyboard reporting behaves differently.

The official nightly encoder explicitly avoids emitting bare Escape when
disambiguation is requested; this is a native upstream fix for the Escape side
of the interaction. The nightly was not installed over the stable app. It does
not fix the numbered shortcuts, as demonstrated above. No Escape remapping or
timeout workaround was deployed.

## Ghostty 1.3.1 trial

The user's physical-key capture in Ghostty with Kitty flags 7 produced correct
Ctrl+Shift key-down events for 1, 2, 3, [ and ]. A subsequent automated test sent
logical events directly to Ghostty and confirmed 4–9, Escape, and Ctrl+Shift+Alt
left/right. Escape arrived as `ESC [ 27 u` with a separate release event.

On 2026-09-13, `ghostty/config.ghostty` was deployed through the terminal slice.
It clears host shortcuts, preserves Option-character composition, and binds
paste, font controls and Ctrl+Q with confirmation. Normal launch attaches to the
existing default Herdr session. Raycast Alt+T still opens WezTerm during the trial.

The trial used native Ctrl+Shift+bracket bindings alongside U/I; both were
replaced by comma/period tab bindings on 2026-09-13.

The deployed configuration was exercised using native macOS key events sent
directly to an isolated Ghostty GUI, with Kitty flags 7:

- Ctrl+Shift+1–9, comma/period and brackets retained modifier 6 on key-down.
- Escape arrived encoded as `ESC [ 27 u`, with a separate release event.
- Ctrl+Shift+Alt+left/right retained modifier 8; Ctrl+Cmd+1 retained modifier 13.
- Polish Pro Option-letter and Option+Shift-letter input produced all nine
  lowercase and uppercase Polish characters.
- Ctrl+Shift+V delivered clipboard text with bracketed-paste delimiters.
- Ctrl+Cmd+= / - / 0 increased, decreased and reset font size, observed through
  terminal grid dimensions. Ctrl+Q opened the native quit confirmation.

An isolated named Herdr session confirmed new tabs, comma/period tab switching,
pane splitting, and copy-mode entry/exit with Escape. The temporary session and
input receiver were removed afterward; the default session was not used for
mutation tests.

These synthetic events test Ghostty's native encoder, not physical hardware or
Karabiner interception. The deployed Karabiner rules now include Ghostty for
both left and right Cmd/Ctrl swaps; physical right-side behavior still needs
daily-use confirmation. Screen capture was blocked by macOS permissions, so
appearance was configured from WezTerm's settings, not visually certified.

### Neovim Ctrl+Tab

Ghostty explicitly sends `CSI 9;5u` for Ctrl+Tab. Tested passing this sequence through an isolated Herdr client into Neovim: it toggles the alternate buffer. Reload Ghostty configuration after changing the binding; the physical macOS/Karabiner shortcut still needs an interactive check.

### Shared navigation and resize commands

Herdr custom shortcuts supply `HERDR_ACTIVE_PANE_ID`, not the child-process variable `HERDR_PANE_ID`. The split helper uses the active ID; using the other variable made navigation and resize fail silently. Regression checks include a stale child-process ID to ensure the active pane wins. An isolated Herdr client verified navigation and resizing in Neovim and shell panes. Ghostty explicitly forwards Ctrl+arrows and Ctrl+Shift+Alt+arrows/HJKL, preserving ordinary Option-letter composition. Reload Ghostty configuration after changing these bindings. Physical keys with the terminal Karabiner swap: Command+arrows to navigate; Command+Shift+Option+arrows/HJKL to resize.

Ctrl+Shift+arrows also use the shared split helper, rather than Herdr direct-focus actions. The same chord moves within Neovim, crosses into an adjacent Herdr pane at the editor edge, and returns from a shell pane. Verified through an isolated Herdr client. Physical chord after Karabiner: Command+Shift+arrows.
