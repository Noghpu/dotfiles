-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.g.lazyvim_python_lsp = "basedpyright"  -- replaced by ty in lua/plugins/python-lsp.lua
vim.g.snacks_animate = false
vim.o.shell = "fish"

-- OSC 52 clipboard for SSH yanking (async, no paste delay)
vim.o.clipboard = "unnamedplus"

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = function()
      return { vim.fn.getreg("0", 1, true), vim.fn.getregtype("0") }
    end,
    ["*"] = function()
      return { vim.fn.getreg("0", 1, true), vim.fn.getregtype("0") }
    end,
  },
}
