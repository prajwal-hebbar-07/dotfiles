return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 300,
      spec = {
        { "<leader>b", group = "buffer / debug" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lsp / lint" },
        { "<leader>m", group = "modify" },
        { "<leader>q", group = "session" },
        { "<leader>r", group = "run / tasks" },
        { "<leader>s", group = "search / splits" },
        { "<leader>t", group = "tabs" },
        { "<leader>x", group = "diagnostics" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer-local keymaps",
      },
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open({ transient = true, visualSelectionUsage = "auto-detect" })
        end,
        mode = { "n", "x" },
        desc = "Search and replace project",
      },
    },
    opts = {},
  },
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle code outline" },
      { "[s", "<cmd>AerialPrev<CR>", desc = "Previous symbol" },
      { "]s", "<cmd>AerialNext<CR>", desc = "Next symbol" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        min_width = 30,
        default_direction = "prefer_right",
      },
      show_guides = true,
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore session",
      },
      {
        "<leader>qS",
        function()
          require("persistence").select()
        end,
        desc = "Select session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore last session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Do not save session",
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerTaskAction" },
    keys = {
      { "<leader>rr", "<cmd>OverseerRun<CR>", desc = "Run task" },
      { "<leader>rt", "<cmd>OverseerToggle<CR>", desc = "Toggle task list" },
      { "<leader>ra", "<cmd>OverseerTaskAction<CR>", desc = "Task action" },
    },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 12,
        max_height = 20,
      },
    },
  },
}
