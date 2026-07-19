local wezterm = require("wezterm")
local act = wezterm.action

local config = {
	color_scheme = "Kanagawa (Gogh)",

	-- Font preferences
	font = wezterm.font_with_fallback({
		{ family = "JetBrains Mono", weight = "Bold" },
		{ family = "MesloLGS NF", weight = "Regular" },
		"JetBrains Mono",
		"Menlo",
		"Monaco",
	}),
	font_size = 14.0,
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" }, -- disable ligatures

	background = {
		{
			source = {
				File = "/Users/" .. os.getenv("USER") .. "/.config/img/background.jpeg",
			},
			hsb = {
				hue = 0.0,
				saturation = 0.0,
				brightness = 0.5,
			},
			horizontal_align = "Center",
			vertical_align = "Middle",
		},
		{
			source = {
				Color = "#282c35",
			},
			width = "100%",
			height = "100%",
			opacity = 0.5,
		},
	},

	max_fps = 120,
	-- enable_tab_bar = false,
	cursor_blink_rate = 0,

	window_decorations = "RESIZE",
	window_close_confirmation = "NeverPrompt",
	inactive_pane_hsb = {},

	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},

	-- Keybindings
	-- disable_default_key_bindings = true,
	enable_kitty_keyboard = true,
	keys = {
		{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) }, -- for newlines in Claude Code
		{ key = "Tab", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
		{ key = "|", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "_", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
		{
			key = "r",
			mods = "CTRL|SHIFT",
			action = wezterm.action.PromptInputLine({
				description = "Enter new name for tab",
				action = wezterm.action_callback(function(window, pane, line)
					-- line will be nil if they hit Escape without entering anything
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		{
			key = "f",
			mods = "CTRL|SHIFT",
			-- WezTerm has a built-in fuzzy finder specifically for tabs!
			action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|TABS" }),
		},
	},
}

-- Apply smart splits configuration
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
smart_splits.apply_to_config(config, {
	direction_keys = {
		move = { "h", "j", "k", "l" },
		resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
	},
	modifiers = {
		move = "CTRL",
		resize = "ALT",
	},
})

local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
modal.apply_to_config(config)
modal.set_default_keys(config)

wezterm.on("modal.enter", function(name, window, pane)
	modal.set_right_status(window, name)
	modal.set_window_title(pane, name)
end)

wezterm.on("modal.exit", function(name, window, pane)
	window:set_right_status("")
	modal.reset_window_title(pane)
end)

local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
workspace_switcher.zoxide_path = "/opt/homebrew/bin/zoxide"
workspace_switcher.apply_to_config(config)

table.insert(config.keys, {
	key = "s",
	mods = "CTRL|SHIFT",
	action = workspace_switcher.switch_workspace(),
})

-- local agent_deck = wezterm.plugin.require("https://github.com/Eric162/wezterm-agent-deck")
-- agent_deck.apply_to_config(config, {
-- 	update_interval = 500, -- ms between status checks
--
-- 	colors = {
-- 		working = "#A6E22E", -- green: agent processing
-- 		waiting = "#E6DB74", -- yellow: needs input
-- 		idle = "#66D9EF", -- blue: ready
-- 		inactive = "#888888", -- gray: no agent
-- 	},
--
-- 	icons = {
-- 		style = "unicode", -- or 'nerd', 'emoji'
-- 		unicode = { working = "●", waiting = "◔", idle = "○", inactive = "◌" },
-- 	},
--
-- 	notifications = {
-- 		enabled = true,
-- 		on_waiting = true,
-- 		backend = "terminal-notifier", -- or 'native' (default)
-- 		terminal_notifier = {
-- 			sound = "default", -- or 'Ping', 'Glass', 'Funk', etc.
-- 			title = "WezTerm Agent Deck", -- notification title
-- 			activate = true, -- focus WezTerm when notification clicked
-- 		},
-- 	},
-- })

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

config.window_frame = {
	active_titlebar_bg = "none",
	inactive_titlebar_bg = "none",
}

config.colors = {
	tab_bar = {
		background = "none",
		active_tab = { bg_color = "none", fg_color = "#c8c093" },
		inactive_tab = { bg_color = "none", fg_color = "#727169" },
		new_tab = { bg_color = "none", fg_color = "#727169" },
	},
}

return config
