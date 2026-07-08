return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      enable_afterquote = false,
      check_ts = true,
      ts_config = {
        lua = { "string" },
        java = false,
      },
    },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },
  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gb", mode = { "n", "v" } },
      { "gcc", mode = "n" },
      { "gbc", mode = "n" },
    },
    opts = function()
      return {
        padding = true,
        sticky = true,
        ignore = "^$",
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle undo tree" },
    },
  },
  {
    "szw/vim-maximizer",
    keys = {
      { "<leader>mx", "<cmd>MaximizerToggle<CR>", desc = "Maximize split" },
    },
  },
}
