local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"
config.colors = {
  background = "#1a1b26",
}
config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
  "Symbols Nerd Font Mono",
})
config.font_size = 13.0

config.line_height = 1.12
config.window_background_opacity = 0.78
config.macos_window_background_blur = 20
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 5,
}

config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.automatically_reload_config = true
config.audible_bell = "Disabled"
config.adjust_window_size_when_changing_font_size = false
config.harfbuzz_features = { "calt=0" }

config.max_fps = 120
config.animation_fps = 120
config.front_end = "WebGpu"

return config
