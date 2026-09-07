# Raycast and global shortcuts

| Shortcut | Owner / target |
| --- | --- |
| Alt+Space | Raycast |
| Alt+Tab / Alt+Shift+Tab | Existing AltTab |
| Alt+J | Zen (existing browser choice) |
| Alt+T | WezTerm |
| Alt+W | Obsidian |
| Alt+I | Visual Studio Code |
| Alt+P | Raycast Switch Windows |
| Alt+V | Raycast Clipboard History |
| Alt+R | FluidVoice start/stop; existing Polish/English setup |

No messenger or database client is added. Keep Rectangle's existing shortcuts.
Polish Alt letter keys remain reserved. fzf's Alt+C is disabled in zsh.

`settings.rayconfig` is an encrypted settings-category export from Raycast 1.104.28.
The live runtime and extensions under `~/.config/raycast` are not symlinked.
Use Settings → Advanced → Import / Export for restore and capture. Export only
Settings (aliases, hotkeys and favorites); omit clipboard history, chats, notes,
MCP connections, snippets and other private categories. A controlled import
confirmed that this export contains only Settings (including aliases, hotkeys
and favorites). It is versioned; its password is stored separately at
`~/.local/state/dotfiles-backups/20260907-195551/raycast-export-password.txt`.
Keep that password with your private recovery material when moving machines.

A separate full export is in the private backup directory and uses that same
generated password (the password file has mode 600).

Application hotkeys should focus rather than hide on repeat. In this installed
Raycast version, select the Applications group under Extensions and check
Application Hotkey Behaviour. The intended behavior is focus/open only.
Repeated live hotkey tests confirmed that Zen, WezTerm, Obsidian and VS Code
stay focused and visible. Their existing behavior already matches the plan.
Other pre-existing Chrome shortcuts (Cmd+B and Alt+Shift+B for tab search) are
preserved; they are not additional daily bindings introduced by this setup.

References: [Raycast settings](https://manual.raycast.com/settings),
[supported export/import](https://manual.raycast.com/import-export).
