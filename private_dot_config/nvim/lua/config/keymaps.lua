-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
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
