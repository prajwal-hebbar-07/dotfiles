-- User override of NvChad's nvim-tree config.
-- shims the upstream file in lua/nvchad/configs/nvimtree.lua so we can layer
-- our own options onto NvChad's defaults without forking the plugin.

local base = dofile(vim.g.base46_cache .. "nvimtree")

return vim.tbl_deep_extend("force", base or {}, {
  filters = {
    git_ignored = false,
  },
})