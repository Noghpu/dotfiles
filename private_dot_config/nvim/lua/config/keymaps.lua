-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

map("i", "<C-BS>", "<C-W>", { desc = "Delete word" })
map("i", "<C-H>", "<C-W>", { desc = "Delete word" })

-- Move lines with arrow keys
map("n", "<S-Down>", "<C-d>zz", { desc = "Move Down" })
map("n", "<S-Up>", "<C-u>zz", { desc = "Move Up" })
map("i", "<S-Down>", "<ESC><C-d>zzi", { desc = "Move Down" })
map("i", "<S-Up>", "<ESC><C-u>zzi", { desc = "Move Up" })
map("v", "<S-Down>", "<ESC><C-d>zzv", { desc = "Move Down" })
map("v", "<S-Up>", "<ESC><C-u>zzv", { desc = "Move Up" })

-- Move lines with arrow keys
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move Line Down" })
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move Line Up" })
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Line Down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Line Up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move Line Down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move Line Up" })

map({ "n", "v" }, "<Home>", "^", { desc = "Move to first non-whitespace character in the line" })
map({ "i" }, "<Home>", "<c-o>^", { desc = "Move to first non-whitespace character in the line" })
map({ "n", "v" }, "<End>", "$", { desc = "Move to last non-whitespace character in the line" })
map({ "i" }, "<End>", "<c-o>$", { desc = "Move to last non-whitespace character in the line" })

map({ "n", "v" }, "<PageUp>", "<c-u>zz", { desc = "Move half a page up" })
map({ "i" }, "<PageUp>", "<ESC><C-d>zzi", { desc = "Move half a page up" })
map({ "n", "v" }, "<PageDown>", "<c-d>zz", { desc = "Move half a page down" })
map({ "i" }, "<PageDown>", "<ESC><C-d>zzi", { desc = "Move half a page down" })

-- Terminal
map("t", "<ESC><ESC>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Change to Normal Mode" })

-- run file in python
map("n", "<leader>cp", "<CMD>term python % <CR>", { desc = "Run in Python terminal" })
map("n", "<leader>ci", ":!ruff check --select I --fix %", { desc = "Run in Python terminal" })

-- Quarto keymaps
local runner = require("quarto.runner")
map("n", "<leader>jc", runner.run_cell, { desc = "Run {C}ell", silent = true })
map("n", "<leader>jp", runner.run_above, { desc = "Run Cell and {P}revious Cells", silent = true })
map("n", "<leader>jb", runner.run_below, { desc = "Run Cell and {B}elow Cells", silent = true })
map("n", "<leader>ja", runner.run_all, { desc = "Run {A}ll Cells", silent = true })
map("n", "<leader>jt", "<CMD>:split term://ipython<cr>", { desc = "New IPython {T}erminal", silent = true })

map("n", "<leader>jqp", "<cmd>QuartoPreview<cr>", { desc = "{Q}uarto {P}review Document" })
map("n", "<leader>jqq", "<cmd>QuartoClosePreview<cr>", { desc = "{Q}uarto {Q}uit Preview" })
map("n", "<leader>jqd", "<cmd>QuartoRender<cr>", { desc = "{Q}uarto Render {D}ocument" })

local insert_code_chunk = function(lang)
  -- Exit to normal mode
  -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", true)

  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]

  -- Get language context with 1-based coordinates
  local current_lang, _, _, end_row, _ = require("otter.keeper").get_current_language_context()

  if current_lang then
    -- Inside existing code chunk
    -- Set cursor row to below the code block
    cursor_row = end_row + 2 -- 1-based
  else
    local next_cursor = { cursor_row + 1, 0 }
    current_lang, _, _, end_row, _ = require("otter.keeper").get_current_language_context(nil, next_cursor)
    if current_lang then
      -- At the start of a code block, which is not recognized as inside.
      cursor_row = end_row + 2
    end
  end

  local current_line = vim.fn.getline(cursor_row) or ""
  if current_line:gsub("%s+", "") ~= "" then
    vim.fn.append(cursor_row, "") -- append uses 0-based line numbers
    cursor_row = cursor_row + 1
  end

  -- Insert new code chunk with surrounding lines
  vim.fn.append(cursor_row, {
    "```{" .. lang .. "}",
    "",
    "```",
  })

  local below_chunk_line = vim.fn.getline(cursor_row + 4) or ""
  if below_chunk_line:gsub("%s+", "") ~= "" then
    vim.fn.append(cursor_row + 3, "") -- append uses 0-based line numbers
  end

  -- Position cursor in new chunk (2 lines below insertion point)
  vim.api.nvim_win_set_cursor(0, { cursor_row + 2, 0 })

  -- Enter insert mode
  vim.api.nvim_feedkeys("i", "n", false)
end

local insert_python_cell = function()
  insert_code_chunk("python")
end

vim.keymap.set("n", "<leader>jn", insert_python_cell, { desc = "{N}ew Cell", silent = true })

-- Markview keymaps
map("n", "<leader>um", "<cmd>Markview toggleAll<CR>", { desc = "Toggle {M}arkdown Preview", silent = true })

-- vim-slime
local function mark_terminal()
  local job_id = vim.b.terminal_job_id
  vim.print("job_id: " .. job_id)
end

local function set_terminal()
  vim.fn.call("slime#config", {})
end

map("n", "<leader>jm", mark_terminal, { desc = "[m]ark terminal" })
map("n", "<leader>js", set_terminal, { desc = "[s]et terminal" })

local function open_ipython_terminal()
  -- Save the original window
  local orig_win = vim.api.nvim_get_current_win()

  -- Open a vertical split terminal running ipython (with --no-confirm-exit)
  vim.cmd("split term://ipython --no-confirm-exit")

  -- In the new terminal window, retrieve the terminal job ID
  local jobid = vim.b.terminal_job_id or vim.api.nvim_buf_get_var(0, "terminal_job_id")

  -- Switch back to the original window
  vim.api.nvim_set_current_win(orig_win)

  -- Configure vim-slime for the original buffer using the new terminal's job ID
  vim.b.slime_config = { jobid = jobid }

  print("IPython terminal ready. JobID: " .. jobid)
end

-- Key mapping: <leader>i will invoke the function.
vim.keymap.set("n", "<leader>jt", open_ipython_terminal, {
  noremap = true,
  silent = true,
  desc = "Open/Set IPython {T}erminal for Slime",
})
-- General Editing Keybinds
map("i", "<C-BS>", "<C-W>", { desc = "Delete Word", silent = true })
map("n", "<C-LEFT>", "b", { desc = "Skip Word To The Left", silent = true })
map("n", "<C-RIGHT>", "e", { desc = "Skip Word To The Left", silent = true })

-- Buffer/Split navigation
map("n", "<AS-LEFT>", "<cmd>bprevious<cr>", { desc = "Previous Buffer", silent = true })
map("n", "<AS-RIGHT>", "<cmd>bnext<cr>", { desc = "Next Buffer", silent = true })

map("n", "<AC-j>", "<cmd>bprevious<cr>", { desc = "Previous Buffer", silent = true })
map("n", "<AC-l>", "<cmd>bnext<cr>", { desc = "Next Buffer", silent = true })
map("n", "<AC-i>", "<C-W>k", { desc = "Move to Upper Split", silent = true })
map("n", "<AC-k>", "<C-W>j", { desc = "Move to Lower Split", silent = true })
