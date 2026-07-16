return {
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gg", "<cmd>tabnew | Git | only<CR>", desc = "Fugitive status" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        local function nav_hunk(direction)
          gs.nav_hunk(direction, { target = "all" })
        end

        local function close_file_diff()
          local revision_windows = {}

          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local diff_buf = vim.api.nvim_win_get_buf(win)
            local diff_name = vim.api.nvim_buf_get_name(diff_buf)

            if vim.startswith(diff_name, "gitsigns://") then
              table.insert(revision_windows, win)
            end
          end

          if #revision_windows == 0 then
            return false
          end

          for _, win in ipairs(revision_windows) do
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_close(win, false)
            end
          end

          vim.cmd("diffoff!")
          return true
        end

        local function toggle_file_diff()
          if not close_file_diff() then
            gs.diffthis("HEAD", { vertical = true })
          end
        end

        map("n", "]h", function()
          nav_hunk("next")
        end, "Next Git hunk")
        map("n", "[h", function()
          nav_hunk("prev")
        end, "Previous Git hunk")
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage selection")
        map("v", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset selection")
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>gd", toggle_file_diff, "Toggle file diff")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },
}
