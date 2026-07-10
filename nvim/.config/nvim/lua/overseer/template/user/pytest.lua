local function python_command()
  return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python3"
end

local function project_root(dir)
  local marker = vim.fs.find({ "pyproject.toml", "pytest.ini", "setup.cfg", ".git" }, {
    upward = true,
    path = dir,
  })[1]
  return marker and vim.fs.dirname(marker) or dir
end

return {
  generator = function(search)
    if search.filetype ~= "python" then
      return "Not a Python buffer"
    end

    local cwd = project_root(search.dir)
    local file = vim.api.nvim_buf_get_name(0)
    local components = {
      { "on_output_quickfix", open_on_exit = "failure", set_diagnostics = true },
      "on_result_diagnostics",
      "default",
    }

    return {
      {
        name = "pytest: suite",
        builder = function()
          return {
            cmd = { python_command(), "-m", "pytest" },
            cwd = cwd,
            components = components,
          }
        end,
      },
      {
        name = "pytest: current file",
        builder = function()
          return {
            cmd = { python_command(), "-m", "pytest", file },
            cwd = cwd,
            components = components,
          }
        end,
      },
    }
  end,
}
