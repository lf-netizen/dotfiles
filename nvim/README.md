# Neovim

A standalone Neovim 0.12 configuration for reviewing changes, reading code, and editing. `init.lua` loads `lua/config/`; flat `lua/plugins/` specs are managed by lazy.nvim and pinned in `lazy-lock.json`.

Install Neovim 0.12, Git, ripgrep, fd, tree-sitter-cli 0.26.1+, a C compiler, Node/npm, uv, gh and LazyGit. First launch installs plugins and parsers; Mason supplies language tools. Authenticate `gh` for Octo. Project Python environments should provide pytest. CodeDiff downloads its native library on first use. Run `:checkhealth`, `:ConformInfo` and `:LspInfo` to inspect tooling.

## Splits

Keys use logical modifiers after the configured Karabiner Cmd/Ctrl swap.

| Action | Neovim | Herdr |
| --- | --- | --- |
| Split right | Ctrl+backslash | Ctrl+Shift+backslash |
| Split below | Ctrl+minus | Ctrl+Shift+minus |
| Close window/pane | Ctrl+W | Ctrl+Shift+W |
| Navigate | Ctrl+Shift+arrows or Ctrl+arrows; Ctrl+H/J/K/L | Ctrl+Shift+arrows or Ctrl+arrows |
| Resize | Ctrl+Shift+Alt+arrows or H/J/K/L | Same |

Herdr's `splits.py` forwards shared chords when Vim/Neovim is the foreground process. Smart-splits handles editor windows and uses its native Herdr backend at editor edges. A three-cell resize step becomes a 3% Herdr resize step. Outside Herdr, movement stops at the editor edge. Plain Ctrl+H/J/K/L remain available to the shell and other terminal applications. Ctrl+Shift+arrows and Ctrl+arrows share the same routing: move within Neovim first, then cross into Herdr at the editor edge.

## Daily editing

Space is leader. `Ctrl-P` finds files, `Space Space` is smart file search, `Space /` searches text, `Space sr` opens search/replace. `Space e` focuses Neo-tree or returns to the previous editor window; `Space E` toggles it. `s`/`S` invoke Flash. Visual `gS` surrounds a selection; `ys`/`ds`/`cs` surround operators remain available. `Ctrl-Space` expands syntax selection, visual Backspace shrinks it.

`gd`/`gr` find definitions/references; `Space ca/cr/cf/cs` invoke code action, symbol rename, format, and save without formatting. `X` expands the current line's diagnostics until movement or leaving the buffer. `[d`/`]d` navigate diagnostics. `Ctrl-S` saves, `Ctrl-W` closes the window, Shift+H/L switch buffers, Ctrl+Tab visits the alternate buffer. `Space bd` deletes a buffer while preserving windows. `Space p` and visual `Space y` use the system clipboard; `Space y` in normal mode shows yank history. `Space qq` quits with unsaved-change protection, `Space qf` discards unsaved changes and quits all windows, and `Space qs` saves all files and quits.

Extra textobjects use the various-textobjs defaults: `ii`/`ai` indentation, `iq`/`aq` any quotes, `io`/`ao` any brackets, `iv`/`av` values, `ik`/`ak` keys, `in`/`an` numbers, and `i,`/`a,` arguments. Subwords use `is`/`as`; `aS` remains Treesitter scope. Default subword aliases `iS`/`aS` are disabled to avoid that collision. Single-key defaults apply only in visual/operator-pending modes and replace some built-ins there (for example `n` selects near end of line, `L` selects a URL).

Snacks image displays image files and inline images in supported documents, including Markdown. ImageMagick (`brew install imagemagick`) handles JPEG and other conversions; it is already installed on this machine. Open an image normally or use `:lua Snacks.image.hover()` over an image link for a floating preview. Herdr 0.9.1 identifies as libghostty, which Snacks automatically recognizes as supporting graphics and Unicode placeholders; no environment override is needed. Use `:checkhealth snacks` for diagnostics. PDF, video, math and Mermaid conversions can require additional tools.

Python uses ty and Ruff; TypeScript/JavaScript use vtsls and, in configured projects, Biome. Lua uses lua_ls with lazydev. Project-local executables take priority. Conform formats on save with Ruff, StyLua or Biome. Biome is only used where a project configuration exists.

## Review

| Keys | Action |
| --- | --- |
| Space gr | Review current worktree changes in CodeDiff |
| Space gR | Select base and compare its merge base with HEAD |
| Space gw | Review another worktree without changing cwd |
| Space op / oo | List GitHub PRs / open number or URL in Octo |
| Space or / oR / oc | Start / resume review / add comment in Octo |
| Space gp / gP | Preview hunk / blame line |
| [h / ]h | Previous / next Git hunk |
| Space gg | LazyGit |

`:CodeDiff --staged` reviews staged changes. `:CodeDiff <base>...` includes working changes since divergence; `<base>...HEAD` compares committed changes. Octo owns GitHub threads; CodeDiff owns local comparisons. Submission is explicit through `:Octo review submit`; writing an Octo comment can sync it to GitHub. Ordinary Git mutations remain in LazyGit.

`Space cS` opens Trouble's outline on the right. `Space xx/xX` shows all/buffer diagnostics. `Space um` toggles Markdown rendering. `Space n` shows notification history. Search all mappings with `Space sk`; `Space ?` shows buffer-local help.

## Tests and debug

`Space tn/ta/tA/tl` runs nearest/file/project/last tests; `ts/to/tO/tS/tw` opens summary/output/output panel, stops tests, or watches the file. `Space td` debugs the nearest test.

`Space da/dA` sets a breakpoint/conditional breakpoint; `dc/dC` starts or continues/runs to cursor; `di/do/dO` steps into/over/out; `dP/dr/dQ/dK/dd` pauses/reruns/terminates/inspects/toggles DAP View. Debugpy runs via uv and uses the project's Python. There is no persistent debug key mode or standalone Python REPL mapping.

## VS Code

VS Code loads editing options, Flash, surround and Treesitter/textobjects. It owns LSP, completion and UI. `gd`/`gr`, `Space e`, `Space -` and `Space backslash` invoke VS Code actions. No terminal plugins or AI/Harpoon integrations load in this mode.

The native statusline shows the cached Git branch and filepath on the left, diagnostic icons/counts and line:column on the right. The branch icon/name use Kanagawa purple; path and position share a dimmed color on a transparent background. Zero diagnostic counts are hidden; there is no mode indicator or statusline plugin.

Indent guides use the same upright line glyph for normal and active scopes, with explicit non-italic highlights. Ordinary guides are muted; the active scope is brighter. Blank-line guides share the ordinary guide color.
