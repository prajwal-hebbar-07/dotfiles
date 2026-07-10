return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "biomejs" },
      javascriptreact = { "biomejs" },
      typescript = { "biomejs" },
      typescriptreact = { "biomejs" },
      python = { "pylint" },
    }

    local group = vim.api.nvim_create_augroup("hebbar_lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
      group = group,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>ll", function()
      lint.try_lint()
    end, { desc = "Run linting" })
  end,
}
