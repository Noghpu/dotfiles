-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.g.lazyvim_python_lsp = "basedpyright"  -- replaced by ty in lua/plugins/python-lsp.lua
vim.g.snacks_animate = false
vim.o.shell = "fish"

-- OSC 52 clipboard for SSH yanking (async, no paste delay)
local is_windows = vim.env.LC_CLIENT_OS == "windows"
if is_windows then
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
        -- Fall back to "0 register for fast paste
        return { vim.fn.getreg("0", 1, true), vim.fn.getregtype("0") }
      end,
    },
  }

  -- Set after g:clipboard so Neovim uses the custom provider
  vim.o.clipboard = "unnamedplus"
end
