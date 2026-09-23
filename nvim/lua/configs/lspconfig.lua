require("nvchad.configs.lspconfig").defaults()

-- Servers come from PATH — whatever Mason, brew, nvm or `go install` already
-- put there (NvChad prepends Mason's bin to PATH before this runs). A language
-- whose server is absent keeps its highlighting and simply has no LSP. `ols` is
-- never installed from here: it starts only if Odin's own toolchain provided it.
local servers = {
  ts_ls = "typescript-language-server",
  tailwindcss = "tailwindcss-language-server",
  html = "vscode-html-language-server",
  cssls = "vscode-css-language-server",
  jsonls = "vscode-json-language-server",
  gopls = "gopls",
  lua_ls = "lua-language-server",
  ols = "ols",
}

for server, binary in pairs(servers) do
  if vim.fn.executable(binary) == 1 then
    vim.lsp.enable(server)
  end
end
