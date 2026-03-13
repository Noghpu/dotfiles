local map = vim.keymap.set

-- Half-page scroll (centered)
map({ "n", "v" }, "<S-Down>", "<C-d>zz", { desc = "Scroll down" })
map({ "n", "v" }, "<S-Up>", "<C-u>zz", { desc = "Scroll up" })
map({ "n", "v" }, "<PageDown>", "<C-d>zz", { desc = "Scroll down" })
map({ "n", "v" }, "<PageUp>", "<C-u>zz", { desc = "Scroll up" })
map("i", "<S-Down>", "<ESC><C-d>zzi", { desc = "Scroll down" })
map("i", "<S-Up>", "<ESC><C-u>zzi", { desc = "Scroll up" })
map("i", "<PageDown>", "<ESC><C-d>zzi", { desc = "Scroll down" })
map("i", "<PageUp>", "<ESC><C-u>zzi", { desc = "Scroll up" })

-- Home/End to first/last non-whitespace
map({ "n", "v" }, "<Home>", "^", { desc = "First non-blank" })
map("i", "<Home>", "<C-o>^", { desc = "First non-blank" })
map({ "n", "v" }, "<End>", "$", { desc = "End of line" })
map("i", "<End>", "<C-o>$", { desc = "End of line" })

-- Word navigation
map("n", "<C-Left>", "b", { desc = "Word left", silent = true })
map("n", "<C-Right>", "e", { desc = "Word right", silent = true })

-- Move line/selection with Alt+arrows (mirrors LazyVim's <A-j>/<A-k>)
map("n", "<A-Down>", "<A-j>", { remap = true, desc = "Move Down" })
map("n", "<A-Up>", "<A-k>", { remap = true, desc = "Move Up" })
map("i", "<A-Down>", "<A-j>", { remap = true, desc = "Move Down" })
map("i", "<A-Up>", "<A-k>", { remap = true, desc = "Move Up" })
map("v", "<A-Down>", "<A-j>", { remap = true, desc = "Move Down" })
map("v", "<A-Up>", "<A-k>", { remap = true, desc = "Move Up" })

-- Delete word backward (C-H is C-BS in most terminals, keep both for compatibility)
map("i", "<C-H>", "<C-W>", { desc = "Delete word", silent = true })
map("i", "<C-BS>", "<C-W>", { desc = "Delete word", silent = true })

-- Terminal
map("t", "<ESC><ESC>", "<C-\\><C-n>", { silent = true, desc = "Exit terminal mode" })

-- Python
map("n", "<leader>cp", function()
  local file = vim.fn.expand("%:p")
  Snacks.terminal("uv run -s " .. file, { key = "python_run" })
end, { desc = "Run Python script" })

-- LSP
map("n", "<M-d>", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>co", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { "source.organizeImports" }, diagnostics = {} },
  })
end, { desc = "Organize Imports" })

map("n", "<leader>xd", function()
  require("config.diagnostic-picker").pick()
end, { desc = "Workspace diagnostics (all LSPs)" })

local function snake_rename()
  local word = vim.fn.expand("<cword>")
  local s = word:gsub("([%l%d])(%u)", "%1_%2")
  while true do
    local new = s:gsub("(%u)(%u%l)", "%1_%2")
    if new == s then
      break
    end
    s = new
  end
  s = s:lower():gsub("^_", "")
  if s ~= word:lower() then
    vim.lsp.buf.rename(s)
  end
end

-- Must be globally accessible for operatorfunc
_G._snake_rename = function(_)
  snake_rename()
end

vim.keymap.set("n", "<leader>cts", function()
  vim.o.operatorfunc = "v:lua._snake_rename"
  return "g@l"
end, { expr = true, desc = "LSP rename to snake_case" })

-- Pyrefly: insert inferred type annotations into current file
map("n", "<leader>cii", function()
  if vim.bo.filetype ~= "python" then
    Snacks.notify.warn("pyrefly infer: not a Python buffer")
    return
  end
  if vim.fn.executable("pyrefly") ~= 1 then
    Snacks.notify.error("pyrefly not found on PATH")
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].modified then
    local ok = vim.fn.confirm("Buffer has unsaved changes. Save before running pyrefly infer?", "&Yes\n&No") == 1
    if not ok then
      return
    end
  end
  vim.cmd("silent write")
  local file = vim.fn.expand("%:p")
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.system({ "pyrefly", "infer", file }, { text = true }, function(out)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      if out.code ~= 0 then
        local msg = vim.trim(out.stderr or out.stdout or "unknown error")
        Snacks.notify.error("pyrefly infer: " .. msg)
        return
      end
      -- Replace buffer contents to preserve undo tree
      local lines = vim.fn.readfile(file)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.bo[bufnr].modified = false
      pcall(vim.api.nvim_win_set_cursor, 0, cursor)
      Snacks.notify.info("pyrefly infer: annotations inserted")
    end)
  end)
end, { desc = "Pyrefly infer types" })
