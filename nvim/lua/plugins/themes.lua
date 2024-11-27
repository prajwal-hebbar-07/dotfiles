return {
  { 
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        transparent = false,
     })
      vim.cmd.colorscheme("tokyonight-night")
    end 
  }
  -- {
  --   "ellisonleao/gruvbox.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("gruvbox").setup({
  --       transparent_mode = true
  --     })
  --     vim.cmd.colorscheme("gruvbox")
  --   end
  -- }
  -- {
  --     'navarasu/onedark.nvim',
  --     lazy = false,
  --     priority = 1000,
  --     config = function()
  --         require("onedark").setup({
  --             style = "deep",
  --             -- transparent = true,
  --         })
  --         vim.cmd.colorscheme("onedark")
  --     end
  -- }
  -- {
  --   "LunarVim/lunar.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("lunar").setup({
  --       transparent = true,
  --     })
  --     vim.cmd.colorscheme("lunar")
  --   end
  -- }
}
