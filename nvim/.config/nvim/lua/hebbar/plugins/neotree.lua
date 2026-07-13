return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {
      "<leader>e",
      "<cmd>Neotree filesystem toggle left<CR>",
      desc = "Toggle project explorer",
    },
  },
  opts = {
    close_if_last_window = true,
    popup_border_style = "",
    enable_git_status = true,
    enable_diagnostics = true,
    open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
    window = {
      position = "left",
      width = 36,
      mappings = {
        ["Y"] = "copy_relative_path",
        ["gY"] = "copy_absolute_path",
      },
    },
    commands = {
      copy_relative_path = function(state)
        local path = vim.fn.fnamemodify(state.tree:get_node():get_id(), ":.")
        vim.fn.setreg("+", path)
        vim.notify("Copied: " .. path)
      end,
      copy_absolute_path = function(state)
        local path = state.tree:get_node():get_id()
        vim.fn.setreg("+", path)
        vim.notify("Copied: " .. path)
      end,
    },
    filesystem = {
      hijack_netrw_behavior = "disabled",
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
