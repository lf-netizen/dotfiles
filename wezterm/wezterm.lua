local wezterm = require("wezterm")
local act = wezterm.action
local image_path = wezterm.home_dir .. "/.config/img/background.jpeg"
local background = {}
local image = io.open(image_path, "rb")
if image then
	image:close()
	table.insert(background, {
		source = { File = image_path },
		hsb = { hue = 0.0, saturation = 0.0, brightness = 0.5 },
		horizontal_align = "Center",
		vertical_align = "Middle",
	})
end
table.insert(background, {
	source = { Color = "#282c35" },
	width = "100%",
	height = "100%",
	opacity = #background > 0 and 0.5 or 1.0,
})
return {
	default_prog = { "/opt/homebrew/bin/herdr" },
	color_scheme = "Kanagawa (Gogh)",
	font = wezterm.font_with_fallback({ "JetBrains Mono", "MesloLGS NF", "Menlo", "Monaco" }),
	font_size = 14.0,
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
	background = background,
	max_fps = 60,
	cursor_blink_rate = 0,
	window_decorations = "RESIZE",
	window_close_confirmation = "AlwaysPrompt",
	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
	window_frame = { active_titlebar_bg = "none", inactive_titlebar_bg = "none" },
	enable_tab_bar = false,
	send_composed_key_when_left_alt_is_pressed = true,
	send_composed_key_when_right_alt_is_pressed = true,
	enable_kitty_keyboard = true,
	disable_default_key_bindings = true,
	keys = {
		{ key = "q", mods = "CTRL", action = act.QuitApplication },
		{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
		{ key = "=", mods = "CTRL|CMD", action = act.IncreaseFontSize },
		{ key = "-", mods = "CTRL|CMD", action = act.DecreaseFontSize },
		{ key = "0", mods = "CTRL|CMD", action = act.ResetFontSize },
	},
}
