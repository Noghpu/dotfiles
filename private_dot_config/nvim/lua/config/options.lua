-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "basedpyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"
vim.g.snacks_animate = false

vim.o.scrolloff = 10

-- Nushell settings
vim.opt.shelltemp = false
vim.opt.shellredir = "out+err> %s"
vim.o.shellcmdflag = "--login --stdin --no-newline --error-style=plain -c"
vim.opt.shellxescape = ""
vim.opt.shellxquote = ""
vim.opt.shellquote = ""
vim.opt.shellpipe =
"| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"

-- utility method to detect the OS, if you use a custom config the following can be handy
local function getOS()
  if jit then
    return jit.os
  end
  local fh, _ = assert(io.popen("uname -o 2>/dev/null", "r"))
  if fh then
    Osname = fh:read()
  end
  return Osname or "Windows"
end

if getOS() == "Windows" then
  print("Windows OS detected")
  vim.o.shellslash = true
end

-- Set Python host to an environment that has pynvim etc. installed
vim.g.python3_host_prog = (os.getenv("HOME") or os.getenv("USERPROFILE"))
    .. "/.venvs/nvim-py3-host-prog/.venv/Scripts/python.exe"

vim.o.guifont = "JetbrainsMono NF"

require("config.custom_commands")
