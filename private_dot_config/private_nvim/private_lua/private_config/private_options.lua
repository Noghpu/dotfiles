-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
vim.g.snacks_animate = false

-- Prefer fish > nu > system default
if vim.fn.executable("fish") == 1 then
  vim.o.shell = "fish"
elseif vim.fn.executable("nu") == 1 then
  vim.o.shell = "nu"
end

-- OSC 52 clipboard for SSH yanking (async, no paste delay)
local is_windows = vim.env.LC_CLIENT_OS == "windows"
if is_windows then
  local osc52 = require("vim.ui.clipboard.osc52")

  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }

  vim.o.clipboard = "unnamedplus"
end
