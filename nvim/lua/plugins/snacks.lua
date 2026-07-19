-- snacks.nvim scoped to just the picker (file find + word/grep search).
-- snacks ships with LazyVim; this only trims the extras off until you want them.
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      enabled = true,
      -- files + buffers: narrow centered popover, no preview split
      sources = {
        files = { layout = { preset = "select", preview = false } },
        buffers = { layout = { preset = "select", preview = false } },
      },
    },

    -- rest off until you ask for them
    dashboard = { enabled = false },
    explorer = { enabled = true },
    indent = {
      enabled = true,
      -- only the scope bracket, no per-level vertical guides
      indent = { enabled = false },
      scope = { enabled = false },
      -- bracket around the current scope: ┌ │ └ closing the whole block
      chunk = {
        enabled = true,
        char = {
          corner_top = "┌",
          corner_bottom = "└",
          horizontal = "─",
          vertical = "│",
          arrow = ">",
        },
      },
      -- animate the guide drawing on scope change
      animate = {
        enabled = true,
        style = "out",
        easing = "linear",
        duration = { step = 20, total = 300 },
      },
    },
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false },
    words = { enabled = true },
  },
}
