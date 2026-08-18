--!nonstrict

local entries = {}
local fieldsByEntry = {}
local query = ""
local entryIndex = 1
-- Sticky: kept as typed even when the focused entry has fewer fields, and
-- clamped only where it is read.
local fieldIndex = 1
local status = ""

local render

local function shellEscape(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function toLines(text)
  local out = {}
  for line in (text or ""):gmatch("[^\n]+") do
    table.insert(out, line)
  end
  return out
end

local function matches()
  local out = {}

  if query == "" then
    for _, entry in ipairs(entries) do
      table.insert(out, entry)
    end
    return out
  end

  local scored = {}
  for _, entry in ipairs(entries) do
    local score = noctalia.fuzzyScore(query, entry)
    if score then
      table.insert(scored, { entry = entry, score = score })
    end
  end

  table.sort(scored, function(a, b) return a.score > b.score end)
  for _, item in ipairs(scored) do
    table.insert(out, item.entry)
  end
  return out
end

local function selected()
  local list = matches()
  if entryIndex > #list then entryIndex = #list end
  if entryIndex < 1 then entryIndex = 1 end
  return list[entryIndex], list
end

local function fieldsOf(entry)
  if entry == nil then return {} end
  return fieldsByEntry[entry] or {}
end

local function currentField(count)
  if count == 0 then return 0 end
  if fieldIndex > count then return count end
  if fieldIndex < 1 then return 1 end
  return fieldIndex
end

local function loadFields(entry)
  if entry == nil or fieldsByEntry[entry] ~= nil then return end
  -- Claim the slot first so one entry is only ever decrypted once per opening.
  fieldsByEntry[entry] = {}

  noctalia.runAsync("passage-fill fields " .. shellEscape(entry), function(result)
    if result.exitCode ~= 0 then return end
    fieldsByEntry[entry] = toLines(result.stdout)
    render()
  end)
end

local function typeField(index)
  local entry = selected()
  if entry == nil then return end

  local count = #fieldsOf(entry)
  if count > 0 and (index < 1 or index > count) then return end

  panel.close()
  noctalia.runAsync("passage-fill type " .. shellEscape(entry) .. " " .. tostring(index))
end

local function entryRows(list)
  local rows = {}

  for index, entry in ipairs(list) do
    table.insert(rows, ui.row({
      key = "entry-" .. entry,
      fill = index == entryIndex and "outline" or "surface",
      radius = 6,
      paddingH = 8,
      paddingV = 5,
    }, {
      ui.label({
        text = entry,
        maxLines = 1,
        flexGrow = 1,
        fontFamily = "JetBrainsMono Nerd Font",
        color = "on_surface",
      }),
    }))
  end

  if #rows == 0 then
    table.insert(rows, ui.label({
      text = query == "" and "No entries" or "No match",
      color = "on_surface_variant",
      textAlign = "center",
    }))
  end

  return rows
end

local function fieldRows(fields, current)
  local rows = {}

  for index, name in ipairs(fields) do
    table.insert(rows, ui.row({
      key = "field-" .. tostring(index),
      fill = index == current and "outline" or "surface_variant",
      radius = 6,
      paddingH = 8,
      paddingV = 5,
    }, {
      ui.label({
        text = tostring(index) .. "  " .. name,
        maxLines = 1,
        flexGrow = 1,
        fontFamily = "JetBrainsMono Nerd Font",
        color = "on_surface",
      }),
    }))
  end

  return rows
end

render = function()
  local entry, list = selected()
  loadFields(entry)

  local fields = fieldsOf(entry)
  local current = currentField(#fields)

  panel.render(ui.column({ flexGrow = 1, gap = 12, align = "stretch" }, {
    ui.row({ align = "center", gap = 8 }, {
      ui.label({
        text = "Passage",
        fontSize = 18,
        fontWeight = "bold",
        color = "on_surface",
        flexGrow = 1,
      }),
      ui.label({ text = status, color = "on_surface_variant" }),
      ui.button({ glyph = "close", variant = "ghost", onClick = "onClose" }),
    }),
    ui.input({
      key = "search",
      placeholder = "Search entries…",
      value = query,
      focus = true,
      onChange = "onSearchChanged",
      onSubmit = "onSubmit",
    }),
    ui.row({ flexGrow = 1, gap = 20, align = "stretch" }, {
      ui.scroll({
        flexGrow = 1,
        gap = 2,
        align = "stretch",
        paddingH = 8,
        paddingV = 8,
      }, entryRows(list)),
      ui.scroll({
        width = 220,
        gap = 2,
        align = "stretch",
        fill = "surface_variant",
        radius = 8,
        paddingH = 8,
        paddingV = 8,
      }, fieldRows(fields, current)),
    }),
    ui.label({
      text = "⏎ type selected   ⌃1-9 type field   ⌃j/k entry   ⌥j/k field",
      color = "on_surface_variant",
      fontSize = 14,
    }),
  }))
end

function onOpen(_context)
  entries = {}
  fieldsByEntry = {}
  query = ""
  entryIndex = 1
  fieldIndex = 1
  status = "Loading…"
  render()

  local accepted = noctalia.runAsync("passage-fill list", function(result)
    if result.exitCode ~= 0 then
      status = "Could not read the store"
      render()
      return
    end

    entries = toLines(result.stdout)
    status = tostring(#entries) .. " entries"
    render()
  end)

  if not accepted then
    status = "Could not run passage-fill"
    render()
  end
end

function onSearchChanged(value)
  query = value or ""
  entryIndex = 1
  render()
end

function onSubmit()
  local entry = selected()
  local count = #fieldsOf(entry)
  if count == 0 then return end
  typeField(currentField(count))
end

function onKey(chord, pressed)
  if not pressed then return end

  if chord == "ctrl+j" then
    entryIndex += 1
  elseif chord == "ctrl+k" then
    entryIndex -= 1
  elseif chord == "alt+j" or chord == "alt+k" then
    local entry = selected()
    local count = #fieldsOf(entry)
    local step = if chord == "alt+j" then 1 else -1
    local next = currentField(count) + step
    if next > count then next = count end
    if next < 1 then next = 1 end
    fieldIndex = next
  else
    local digit = tonumber(chord:match("^ctrl%+(%d)$"))
    if digit then typeField(digit) end
    return
  end

  render()
end

function onClose()
  panel.close()
end
