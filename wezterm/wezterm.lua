local wezterm = require("wezterm")
local config = wezterm.config_builder()
local action = wezterm.action

config.automatically_reload_config = true
config.enable_tab_bar = false

config.font = wezterm.font("Cascadia Code")
config.font_size = 15
config.line_height = 1.4

config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = 0.7
config.macos_window_background_blur = 30

config.max_fps = 120
config.animation_fps = 120

config.keys = {
	{
		key = "k",
		mods = "CMD",
		action = action.SendKey({ key = "l", mods = "CTRL" }),
	},
	{
		key = "LeftArrow",
		mods = "OPT",
		action = action.SendKey({
			key = "b",
			mods = "ALT",
		}),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = action.SendKey({
			key = "f",
			mods = "ALT",
		}),
	},
}

return config
