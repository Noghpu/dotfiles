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
do
  local real_select ---@type fun(items: any[], opts: table, on_choice: fun(item: any?, idx: integer?))
  local wrapped = false
  local orig_code_action = vim.lsp.buf.code_action

  ---@param item {ctx: {client_id: integer}, action: table}
  ---@param diag_sources table<string, true>
  ---@return integer
  local function action_score(item, diag_sources)
    local score = 0

    local d = item.action.diagnostics
    if type(d) == "table" and #d > 0 then
      score = score - 1000
    end

    local client = vim.lsp.get_client_by_id(item.ctx.client_id)
    if client and diag_sources[client.name:lower()] then
      score = score - 100
    end

    if item.action.isPreferred == true then
      score = score - 10
    end

    if (item.action.kind or ""):find("^quickfix") then
      score = score - 1
    end

    return score
  end

  ---@param items {ctx: {client_id: integer}, action: table}[]
  local function sort_code_actions(items)
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diag_sources = {} ---@type table<string, true>
    for _, d in ipairs(vim.diagnostic.get(0, { lnum = lnum })) do
      if d.source then
        diag_sources[d.source:lower()] = true
      end
    end

    local scored = {} ---@type {item: table, score: integer, idx: integer}[]
    for i, item in ipairs(items) do
      scored[i] = { item = item, score = action_score(item, diag_sources), idx = i }
    end

    table.sort(scored, function(a, b)
      if a.score ~= b.score then
        return a.score < b.score
      end
      return a.idx < b.idx
    end)

    for i, entry in ipairs(scored) do
      items[i] = entry.item
    end
  end

  ---@param opts? vim.lsp.buf.code_action.Opts
  vim.lsp.buf.code_action = function(opts)
    if not wrapped then
      real_select = vim.ui.select
    end
    wrapped = true

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(items, select_opts, on_choice)
      vim.ui.select = real_select
      wrapped = false

      if select_opts.kind == "codeaction" then
        sort_code_actions(items)
      end

      return real_select(items, select_opts, on_choice)
    end

    return orig_code_action(opts)
  end
end

-- Treesitter textobject swap keymaps (buffer-local, filetype-aware)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_swap", { clear = true }),
  callback = function(ev)
    if not LazyVim.treesitter.have(vim.bo[ev.buf].filetype, "textobjects") then
      return
    end

    local s = require("nvim-treesitter-textobjects.swap")
    local maps = {
      { "<leader>tsa", "swap_next", "@parameter.inner", "Swap arg next" },
      { "<leader>tsA", "swap_previous", "@parameter.inner", "Swap arg prev" },
      { "<leader>tsf", "swap_next", "@function.outer", "Swap function next" },
      { "<leader>tsF", "swap_previous", "@function.outer", "Swap function prev" },
    }
    for _, m in ipairs(maps) do
      vim.keymap.set("n", m[1], function()
        s[m[2]](m[3], "textobjects")
      end, { buffer = ev.buf, desc = m[4], silent = true })
    end
  end,
})
