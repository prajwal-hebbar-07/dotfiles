vim.opt_local.textwidth = 80
vim.opt_local.spell = true
vim.opt_local.linebreak = true
vim.opt_local.smartindent = false
vim.opt_local.formatoptions:append("t")

local function toggle_prefix(prefix)
  local line = vim.api.nvim_get_current_line()

  if line:match("^%s*" .. vim.pesc(prefix)) then
    vim.api.nvim_set_current_line(line:gsub("^(%s*)" .. vim.pesc(prefix) .. "%s*", "%1", 1))
  elseif not line:match("^%s*$") then
    vim.api.nvim_set_current_line(prefix .. " " .. line)
  end
end

local function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()

  if line:match("^%s*%- %[ %]") then
    vim.api.nvim_set_current_line(line:gsub("%[ %]", "[x]", 1))
  elseif line:match("^%s*%- %[x%]") or line:match("^%s*%- %[X%]") then
    vim.api.nvim_set_current_line(line:gsub("%[[xX]%]", "[ ]", 1))
  elseif line:match("^%s*%- ") then
    vim.api.nvim_set_current_line(line:gsub("^(%s*%-)%s*", "%1 [ ] ", 1))
  elseif not line:match("^%s*$") then
    vim.api.nvim_set_current_line("- [ ] " .. line)
  end
end

local function toggle_heading(level)
  local line = vim.api.nvim_get_current_line()
  local content = line:gsub("^#+%s*", "")
  local current = line:match("^(#+)")

  if current and #current == level then
    vim.api.nvim_set_current_line(content)
  else
    vim.api.nvim_set_current_line(string.rep("#", level) .. " " .. content)
  end
end

vim.keymap.set("n", "tb", function() toggle_prefix("-") end, { buffer = true, desc = "Toggle bullet" })
vim.keymap.set("n", "tn", function() toggle_prefix("1.") end, { buffer = true, desc = "Toggle numbered item" })
vim.keymap.set("n", "tc", toggle_checkbox, { buffer = true, desc = "Toggle checkbox" })
vim.keymap.set("n", "tt", toggle_checkbox, { buffer = true, desc = "Toggle task state" })

for level = 1, 6 do
  vim.keymap.set("n", "<leader>h" .. level, function()
    toggle_heading(level)
  end, { buffer = true, desc = "Toggle H" .. level })
end
