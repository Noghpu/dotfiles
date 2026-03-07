-- Unified workspace diagnostic picker
-- Runs CLI adapters for all attached LSPs in parallel,
-- groups results by (source, code), opens in Snacks picker.
--
-- Keymap: <leader>xd (add to keymaps.lua)
-- Filter shortcuts in picker: <C-r> ruff, <C-t> ty, <C-y> pyrefly, <C-b> basedpyright, <C-z> zuban

local M = {}

-- Parsers ────────────────────────────────────────────────────

--- ty check --output-format=gitlab (JSON array)
local function parse_ty_gitlab(stdout, root)
  local ok, entries = pcall(vim.json.decode, stdout)
  if not ok or type(entries) ~= "table" then
    return {}
  end
  local diags = {}
  for _, d in ipairs(entries) do
    local loc = d.location or {}
    local pos = (loc.positions or {}).begin or {}
    local file = loc.path or ""
    if not vim.startswith(file, "/") then
      file = root .. "/" .. file
    end
    -- description format: "check_name: human message"
    local msg = (d.description or ""):gsub("^[%w%-]+:%s*", "")
    diags[#diags + 1] = {
      code = d.check_name or "unknown",
      message = msg,
      filename = file,
      lnum = pos.line or 0,
      col = pos.column or 0,
      severity = d.severity == "critical" and "E" or (d.severity == "major" and "E" or "W"),
    }
  end
  return diags
end

--- SEVERITY message [tag]\n --> file:line:col (pyrefly)
local function parse_pyrefly(stdout, root)
  local diags = {}
  local lines = vim.split(stdout or "", "\n")
  local i = 1
  while i <= #lines do
    local sev, msg, tag = lines[i]:match("^(%u+)%s+(.-)%s+%[([%w%-]+)%]$")
    if sev and tag then
      for j = i + 1, math.min(i + 3, #lines) do
        local file, lnum, col = lines[j]:match("%-%-?>%s+(.+):(%d+):(%d+)")
        if file then
          if not vim.startswith(file, "/") then
            file = root .. "/" .. file
          end
          diags[#diags + 1] = {
            code = tag,
            message = msg,
            filename = file,
            lnum = tonumber(lnum),
            col = tonumber(col),
            severity = sev == "ERROR" and "E" or "W",
          }
          i = j
          break
        end
      end
    end
    i = i + 1
  end
  return diags
end

--- ruff check --output-format json
local function parse_ruff_json(stdout, root)
  local ok, entries = pcall(vim.json.decode, stdout)
  if not ok or type(entries) ~= "table" then
    return {}
  end
  local diags = {}
  for _, d in ipairs(entries) do
    local filename = d.filename or ""
    if not vim.startswith(filename, "/") then
      filename = root .. "/" .. filename
    end
    diags[#diags + 1] = {
      code = d.code or "unknown",
      message = d.message or "",
      filename = filename,
      lnum = d.location and d.location.row or 0,
      col = d.location and d.location.column or 0,
      severity = "W",
    }
  end
  return diags
end

--- basedpyright --outputjson . (JSON array, 0-indexed lines)
local function parse_basedpyright_json(stdout, root)
  local ok, entries = pcall(vim.json.decode, stdout)
  if not ok or type(entries) ~= "table" then
    return {}
  end
  -- May be wrapped under generalDiagnostics or be a flat array
  if entries.generalDiagnostics then
    entries = entries.generalDiagnostics
  end
  local diags = {}
  for _, d in ipairs(entries) do
    local filename = d.file or ""
    if not vim.startswith(filename, "/") then
      filename = root .. "/" .. filename
    end
    local start = d.range and d.range.start
    diags[#diags + 1] = {
      code = d.rule or "unknown",
      message = d.message or "",
      filename = filename,
      lnum = start and (start.line + 1) or 0,
      col = start and start.character or 0,
      severity = d.severity == "error" and "E" or "W",
    }
  end
  return diags
end

--- file:line:col: severity: message  [code] (zuban --show-column-numbers --no-pretty)
local function parse_zuban(stdout, root)
  local diags = {}
  for line in (stdout or ""):gmatch("[^\n]+") do
    local file, lnum, col, sev, msg, code = line:match("^(.+):(%d+):(%d+):%s*(%w+):%s*(.-)%s+%[([%w%-]+)%]$")
    if file then
      if not vim.startswith(file, "/") then
        file = root .. "/" .. file
      end
      diags[#diags + 1] = {
        code = code,
        message = msg,
        filename = file,
        lnum = tonumber(lnum),
        col = tonumber(col),
        severity = sev == "error" and "E" or "W",
      }
    end
  end
  return diags
end

-- Adapters ───────────────────────────────────────────────────
-- Each adapter: { client_name, shortcut, cmd(root), parse(stdout, root) }
-- Only runs when its LSP client is attached.

M.adapters = {
  ruff = {
    client_name = "ruff",
    shortcut = "<C-r>",
    cmd = function()
      return { "ruff", "check", "--output-format", "json", "--quiet" }
    end,
    parse = parse_ruff_json,
  },

  ty = {
    client_name = "ty",
    shortcut = "<C-t>",
    cmd = function()
      return { "ty", "check", "--output-format=gitlab" }
    end,
    parse = parse_ty_gitlab,
  },

  pyrefly = {
    client_name = "pyrefly",
    shortcut = "<C-y>",
    cmd = function()
      return { "pyrefly", "check" }
    end,
    parse = parse_pyrefly,
  },

  basedpyright = {
    client_name = "basedpyright",
    shortcut = "<C-b>",
    cmd = function()
      return { "basedpyright", "--outputjson" }
    end,
    parse = parse_basedpyright_json,
  },

  zuban = {
    client_name = "zuban",
    shortcut = "<C-z>",
    cmd = function()
      return { "zuban", "check", "--show-column-numbers", "--no-pretty" }
    end,
    parse = parse_zuban,
  },
}

-- Grouping ───────────────────────────────────────────────────

--- Group flat diagnostics by (source, code) into picker items
---@param diags table[]
---@return table[]
local function group_diags(diags)
  local groups = {}
  for _, d in ipairs(diags) do
    local key = d.source .. "\0" .. d.code
    if not groups[key] then
      groups[key] = { source = d.source, code = d.code, count = 0, diags = {} }
    end
    groups[key].count = groups[key].count + 1
    groups[key].diags[#groups[key].diags + 1] = d
  end
  local items = vim.tbl_values(groups)
  table.sort(items, function(a, b)
    if a.source ~= b.source then
      return a.source < b.source
    end
    return a.count > b.count
  end)
  for _, item in ipairs(items) do
    item.text = ("%s %s %d"):format(item.source, item.code, item.count)
  end
  return items
end

-- Core ───────────────────────────────────────────────────────

function M.pick()
  -- Collect matched adapters before opening the picker
  local clients = vim.lsp.get_clients()
  local matched = {}
  local seen = {}

  for _, client in ipairs(clients) do
    for key, adapter in pairs(M.adapters) do
      if client.name == adapter.client_name and not seen[key] then
        seen[key] = true
        matched[#matched + 1] = {
          adapter = adapter,
          root = client.root_dir or vim.fn.getcwd(),
        }
      end
    end
  end

  if #matched == 0 then
    Snacks.notify.info("No diagnostic adapters matched attached LSPs")
    return
  end

  -- Build per-source filter shortcuts
  local input_keys = {}
  local actions = {}
  for key, adapter in pairs(M.adapters) do
    if adapter.shortcut then
      local action_name = "filter_" .. key
      input_keys[adapter.shortcut] = { action_name, mode = { "i", "n" }, desc = adapter.client_name }
      actions[action_name] = function(picker)
        local buf = picker.input.buf
        local current = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
        local name = adapter.client_name
        local new = current == name and "" or name
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { new })
        picker:find()
      end
    end
  end

  -- Shared items list — mutated by callbacks, read by picker
  local all_items = {}
  local pending = #matched
  local picker

  local function refresh_title()
    if not picker then
      return
    end
    if pending > 0 then
      picker.opts.title = ("Workspace Diagnostics (%d/%d)"):format(#matched - pending, #matched)
    else
      picker.opts.title = "Workspace Diagnostics"
    end
  end

  picker = Snacks.picker({
    title = ("Workspace Diagnostics (0/%d)"):format(#matched),
    items = all_items,
    show_empty = true,
    layout = { preset = "select" },
    win = { input = { keys = input_keys } },
    actions = actions,
    format = function(item)
      return {
        { ("%4d"):format(item.count), "Number" },
        { "  " },
        { ("%-14s"):format(item.source), "Title" },
        { ("%-16s"):format(item.code), "DiagnosticWarn" },
      }
    end,
    confirm = function(p, _)
      p:close()
      local selected = p:selected({ fallback = true })
      local qf = {}
      for _, sel in ipairs(selected) do
        for _, d in ipairs(sel.diags) do
          qf[#qf + 1] = {
            filename = d.filename,
            lnum = d.lnum,
            col = d.col,
            text = ("[%s:%s] %s"):format(d.source, d.code, d.message),
            type = d.severity,
          }
        end
      end
      local labels = vim.tbl_map(function(s)
        return s.source .. ":" .. s.code
      end, selected)
      vim.fn.setqflist({}, " ", { title = table.concat(labels, ", "), items = qf })
      vim.cmd("Trouble qflist open")
    end,
  })

  -- Launch all adapter commands in parallel outside the picker
  for _, m in ipairs(matched) do
    vim.system(m.adapter.cmd(m.root), { text = true, cwd = m.root }, function(out)
      vim.schedule(function()
        if out.code == 0 or out.code == 1 then
          local diags = m.adapter.parse(out.stdout or "", m.root)
          for _, d in ipairs(diags) do
            d.source = m.adapter.client_name
          end
          local new_items = group_diags(diags)
          for _, item in ipairs(new_items) do
            all_items[#all_items + 1] = item
          end
        end
        pending = pending - 1
        -- Refresh picker if it's still open
        if picker and not picker.closed then
          refresh_title()
          picker:find()
        end
      end)
    end)
  end
end

return M
