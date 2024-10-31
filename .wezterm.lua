-- Pull in the wezterm api
local wezterm = require("wezterm")

-- This will hold the configuration
local config = wezterm.config_builder()

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 14
config.line_height = 1.6

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.6

-- config.color_scheme = "Solarized Dark Higher Contrast"
config.color_scheme = "Catppuccin Mocha"
config.keys = {
	{
		key = "f",
		mods = "CMD",
		action = wezterm.action.ToggleFullScreen,
	},
}

return config
