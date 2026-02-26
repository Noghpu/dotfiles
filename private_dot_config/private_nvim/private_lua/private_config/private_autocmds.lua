-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- Sort code actions: prioritize LSP clients that produced diagnostics on current line
-- Sort code actions: diagnostic-provider first, then isPreferred, then quickfix
local select = vim.ui.select
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(items, opts, on_choice)
  if opts.kind == "codeaction" then
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diag_sources = {}
    for _, d in ipairs(vim.diagnostic.get(0, { lnum = lnum })) do
      if d.source then
        diag_sources[d.source:lower()] = true
      end
    end

    table.sort(items, function(a, b)
      local function score(item)
        local client = vim.lsp.get_client_by_id(item.ctx.client_id)
        local from_diag = client and diag_sources[client.name:lower()] or false
        local preferred = item.action.isPreferred == true
        local quickfix = (item.action.kind or ""):find("^quickfix") ~= nil

        -- Lower score = higher priority
        if from_diag and preferred then
          return 0
        end
        if from_diag and quickfix then
          return 1
        end
        if from_diag then
          return 2
        end
        if preferred then
          return 3
        end
        if quickfix then
          return 4
        end
        return 5
      end
      return score(a) < score(b)
    end)
  end
  return select(items, opts, on_choice)
end
