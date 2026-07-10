local commands = {
  javascript = { "node" },
  lua = { "nvim", "-l" },
  python = { "python3" },
  sh = { "bash" },
  typescript = { "node" },
}

return {
  name = "run current file",
  builder = function()
    local cmd = vim.deepcopy(commands[vim.bo.filetype])
    table.insert(cmd, vim.fn.expand("%:p"))

    return {
      cmd = cmd,
      components = {
        { "on_output_quickfix", open_on_exit = "failure", set_diagnostics = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = {
    filetype = vim.tbl_keys(commands),
    callback = function(search)
      local command = commands[search.filetype]
      return command and vim.fn.executable(command[1]) == 1
    end,
  },
}
