# macOS modified-number and bracket input

Current installed WezTerm, verified during cleanup: nightly
`20260906-101927-d2f3f05b`. WezTerm remains the chosen host because the setup also
needs Windows support. Ghostty was a diagnostic comparison, not a migration.
The findings below retain the stable/nightly distinction from the tests.

Reproduced 2026-09-07 with installed WezTerm
`20240203-110809-5046fc22` and the official nightly
`20260906-101927-d2f3f05b`. Herdr is 0.8.2.

## Reproduction and evidence

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

Confirmed terminal input bug; **not fixed**. No translation bindings, custom
binaries, reporting-mode injection, or Karabiner changes were deployed. The
nightly was tested separately, not installed over the stable app.

A proper fix needs to preserve raw modifier and key identity in WezTerm's Kitty
encoding, including Ctrl+Shift punctuation, while retaining composed-text input.
Regression coverage should include key-down and key-up for 1–9 and brackets,
flags 7 and 31, and Polish Option-letter composition. Changing the initial
plain-text check alone is insufficient for the bracket key identity issue.

Current usable navigation: Ctrl+Shift+J/K for agents, H/L for workspaces, U/I for
tabs, Ctrl+Shift+P navigator, and Ctrl+Cmd+1–9 for workspaces. Ctrl+Shift+1–9 is
still configured for agents but is affected by this bug.

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

A temporary Ghostty config at `/tmp/ghostty-herdr-test/config` clears host
shortcuts, preserves Option-character composition, and adds only paste and font
controls. It attaches to the existing default Herdr session. Raycast still opens
WezTerm; no Ghostty config was deployed into the live config directory.

Native Ctrl+Shift+bracket bindings are restored alongside U/I for the trial.
Actual daily use, Polish letter input, and right-side modifier behavior still
need human confirmation. The existing Karabiner rules include Ghostty for the
left Cmd/Ctrl swap, but not for the right Cmd/Ctrl swap.
