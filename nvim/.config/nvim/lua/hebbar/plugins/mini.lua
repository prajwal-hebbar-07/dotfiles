return {
  {
    "echasnovski/mini.surround",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      mappings = {
        add = "sa",
        delete = "ds",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "ca",
        update_n_lines = "sn",
      },
    },
  },
  {
    "echasnovski/mini.trailspace",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("mini.trailspace").setup({ only_in_normal_buffers = true })
      vim.keymap.set("n", "<leader>cw", function()
        require("mini.trailspace").trim()
      end, { desc = "Trim whitespace" })
    end,
  },
  {
    "echasnovski/mini.splitjoin",
    version = false,
    config = function()
      local splitjoin = require("mini.splitjoin")
      splitjoin.setup({ mappings = { toggle = "" } })
      vim.keymap.set({ "n", "x" }, "sj", splitjoin.join, { desc = "Join arguments" })
      vim.keymap.set({ "n", "x" }, "sk", splitjoin.split, { desc = "Split arguments" })
    end,
  },
}
