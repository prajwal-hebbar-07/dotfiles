-- Pale Knight — the workshop palette as a base46 theme.
--
-- Same colours as ghostty/themes/pale-knight, tmux/tmux.conf and zsh/zshrc, so
-- an empty buffer and the terminal behind it are one surface. Accents are equal
-- weight by design: hue carries the meaning, nothing shouts.

local c = {
  void      = "#0f111a", -- the abyss, terminal ground
  tomb      = "#0b0d14", -- below the ground, for sidebars
  grave     = "#171a26", -- statusline ground
  vault     = "#1d2030",
  crypt     = "#32334a", -- raised cell, ghostty ANSI 0
  shade     = "#444364", -- selection
  slate     = "#5a5d80",
  stone     = "#696e93", -- comments, dim text, ghostty ANSI 8
  ash       = "#9297ba", -- punctuation, quiet structure
  bone      = "#a6accd", -- body text, ghostty foreground
  pale      = "#d4d7f1", -- pale king white, active text
  soul      = "#5cb1d2", -- cyan, focus and life — the cursor
  spirit    = "#76cbed", -- bright cyan
  lifeblood = "#86a4e1", -- blue, secondary accent
  vein      = "#9fbdfc", -- bright blue
  infection = "#c39e5c", -- amber, wants attention
  fever     = "#ddb875", -- bright amber
  essence   = "#ba92d5", -- violet, quiet metadata
  wraith    = "#d3abf0", -- bright violet
  green     = "#91b171", -- ghostty ANSI 2 — added
  moss      = "#aaca89", -- ghostty ANSI 10
  red       = "#da8c8d", -- ghostty ANSI 1 — removed
  blood     = "#f5a5a6", -- ghostty ANSI 9
}

local M = {}

M.base_30 = {
  white = c.pale,
  darker_black = c.tomb,
  black = c.void, -- nvim bg
  black2 = c.grave,
  one_bg = c.vault,
  one_bg2 = c.crypt,
  one_bg3 = c.shade,
  grey = c.shade,
  grey_fg = c.slate,
  grey_fg2 = c.stone,
  light_grey = c.stone,
  red = c.red,
  baby_pink = c.blood,
  pink = c.blood,
  line = c.crypt, -- for lines like vertsplit
  green = c.green,
  vibrant_green = c.moss,
  nord_blue = c.vein,
  blue = c.lifeblood,
  yellow = c.infection,
  sun = c.fever,
  purple = c.wraith,
  dark_purple = c.essence,
  teal = c.spirit,
  orange = c.fever,
  cyan = c.soul,
  statusline_bg = c.grave,
  lightbg = c.crypt,
  pmenu_bg = c.soul,
  folder_bg = c.lifeblood,
}

M.base_16 = {
  base00 = c.void,
  base01 = c.grave,
  base02 = c.crypt,
  base03 = c.stone,
  base04 = c.ash,
  base05 = c.bone,
  base06 = c.pale,
  base07 = c.pale,
  base08 = c.red,
  base09 = c.infection,
  base0A = c.soul,
  base0B = c.green,
  base0C = c.spirit,
  base0D = c.lifeblood,
  base0E = c.essence,
  base0F = c.red,
}

M.polish_hl = {
  defaults = {
    Cursor = { fg = c.void, bg = c.soul },
    Visual = { fg = c.pale, bg = c.shade },
    Search = { fg = c.void, bg = c.infection },
    IncSearch = { fg = c.void, bg = c.soul },
    CurSearch = { fg = c.void, bg = c.soul },
    WinSeparator = { fg = c.shade, bg = c.void },
  },
  git = {
    DiffAdd = { fg = c.green },
    DiffChange = { fg = c.lifeblood },
    DiffDelete = { fg = c.red },
    DiffText = { fg = c.pale, bg = c.shade },
  },
}

M.type = "dark"

M = require("base46").override_theme(M, "pale-knight")

return M
