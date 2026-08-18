--!nonstrict

local entries = {}
local loadedAtMs = 0
local scanning = false

local CACHE_MS = 60000

local function shellEscape(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function publish(query)
  local results = {}

  for _, entry in ipairs(entries) do
    local score = if query == "" then 1 else noctalia.fuzzyScore(query, entry)
    if score then
      table.insert(results, {
        id = entry,
        title = entry,
        glyph = "key",
        score = score,
      })
    end
  end

  launcher.setResults(query, results)
end

function onQuery(query)
  if scanning then return end

  if noctalia.nowMs() - loadedAtMs < CACHE_MS then
    publish(query)
    return
  end

  scanning = true
  local accepted = noctalia.runAsync("passage-fill list", function(result)
    scanning = false

    if result.exitCode ~= 0 then
      noctalia.notifyError("Passage", "Could not read the store")
      return
    end

    entries = {}
    for line in (result.stdout or ""):gmatch("[^\n]+") do
      table.insert(entries, line)
    end
    loadedAtMs = noctalia.nowMs()
    publish(query)
  end)

  if not accepted then
    scanning = false
    noctalia.notifyError("Passage", "Could not run passage-fill")
  end
end

function onActivate(id)
  -- Field 1 is the password.
  noctalia.runAsync("passage-fill type " .. shellEscape(id) .. " 1")
end
