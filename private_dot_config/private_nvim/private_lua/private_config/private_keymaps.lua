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
map("n", "<leader>co", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { "source.organizeImports" }, diagnostics = {} },
  })
end, { desc = "Organize Imports" })
