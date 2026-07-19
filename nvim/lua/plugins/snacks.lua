-- snacks.nvim scoped to just the picker (file find + word/grep search).
-- snacks ships with LazyVim; this only trims the extras off until you want them.
return {
  "folke/snacks.nvim",
  opts = {
    picker = { enabled = true },

    -- rest off until you ask for them
    dashboard = { enabled = false },
    explorer = { enabled = true },
    indent = { enabled = false },
    notifier = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
}
