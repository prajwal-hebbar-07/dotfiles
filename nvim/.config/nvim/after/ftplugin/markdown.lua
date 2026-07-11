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

-- Plan review: insert an `@me` note for Claude below the cursor and start typing.
vim.keymap.set("n", "<leader>pc", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, { "<!-- @me:  -->" })
  vim.api.nvim_win_set_cursor(0, { row + 1, 10 })
  vim.cmd("startinsert")
end, { buffer = true, desc = "Insert a plan-review comment for Claude" })

-- Plan review: send this plan (with its `@me` comments) back to the Claude Code
-- pane that opened the split. Only active when CLAUDE_PANE is set, which the
-- /plan skill does via `tmux split-window -e CLAUDE_PANE=...`.
vim.keymap.set("n", "<leader>pr", function()
  local pane = vim.env.CLAUDE_PANE
  if not pane or pane == "" then
    vim.notify("Not in a plan-review session (CLAUDE_PANE unset)", vim.log.levels.WARN)
    return
  end

  vim.cmd("silent write")
  local file = vim.fn.expand("%:p")

  -- Send the slash command literally (`-l`), then Enter as a real key so Claude
  -- submits it. Two calls, ordered, because `-l` would make Enter literal too.
  vim.system({ "tmux", "send-keys", "-t", pane, "-l", "/plan-review " .. file }, {}, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify("plan-review: tmux send-keys failed", vim.log.levels.ERROR)
      end)
      return
    end
    vim.system({ "tmux", "send-keys", "-t", pane, "Enter" })
    vim.schedule(function()
      vim.notify("Sent plan for review → Claude")
    end)
  end)
end, { buffer = true, desc = "Send plan comments to Claude for review" })
