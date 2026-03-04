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

-- Ruff workspace diagnostics: pick a code → open matching files in trouble
map("n", "<leader>xr", function()
	local clients = vim.lsp.get_clients({ name = "ruff" })
	if #clients == 0 then
		Snacks.notify.warn("ruff LSP not attached")
		return
	end
	local root = clients[1].root_dir

	vim.system({ "ruff", "check", "--statistics" }, { text = true, cwd = root }, function(out)
		vim.schedule(function()
			if out.code ~= 0 and out.code ~= 1 then
				Snacks.notify.error("ruff: " .. (out.stderr or "unknown error"))
				return
			end

			local items = {}
			for line in (out.stdout or ""):gmatch("[^\n]+") do
				local count, code, name = line:match("^%s*(%d+)%s+(%S+)%s+(.+)")
				if code then
					items[#items + 1] = {
						text = ("%s %s %d"):format(code, name, count),
						code = code,
						count = tonumber(count),
						name = vim.trim(name),
					}
				end
			end
			table.sort(items, function(a, b)
				return a.count > b.count
			end)

			if #items == 0 then
				Snacks.notify.info("No ruff diagnostics")
				return
			end

			Snacks.picker({
				title = "Ruff Diagnostics",
				items = items,
				layout = { preset = "select" },
				format = function(item)
					return {
						{ ("%4d"):format(item.count), "Number" },
						{ "  " },
						{ ("%-12s"):format(item.code), "DiagnosticWarn" },
						{ item.name, "Comment" },
					}
				end,
				confirm = function(picker, item)
					picker:close()
					local selected = picker:selected({ fallback = true })
					local codes = vim.tbl_map(function(s)
						return s.code
					end, selected)
					local ruff_select = table.concat(codes, ",")
					vim.system(
						{ "ruff", "check", "--select", ruff_select, "--output-format", "json" },
						{ text = true, cwd = root },
						function(r)
							vim.schedule(function()
								local ok, diags = pcall(vim.json.decode, r.stdout or "")
								if not ok or #diags == 0 then
									Snacks.notify.info("No results for " .. item.code)
									return
								end
								local qf = {}
								for _, d in ipairs(diags) do
									qf[#qf + 1] = {
										filename = d.filename,
										lnum = d.location.row,
										col = d.location.column,
										text = ("[%s] %s"):format(d.code, d.message),
										type = "W",
									}
								end
								vim.fn.setqflist({}, " ", { title = "ruff: " .. item.code, items = qf })
								vim.cmd("Trouble qflist open")
							end)
						end
					)
				end,
			})
		end)
	end)
end, { desc = "Ruff diagnostics by code" })

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

-- Add pyrefly diagnostics to quickfix list
map("n", "<leader>xp", function()
	local root = vim.fn.getcwd()
	local clients = vim.lsp.get_clients({ name = "pyrefly" })
	if #clients > 0 then
		root = clients[1].root_dir or root
	end

	vim.system({ "pyrefly", "check" }, { text = true, cwd = root }, function(out)
		vim.schedule(function()
			local stdout = out.stdout or ""
			if stdout == "" then
				Snacks.notify.info("No pyrefly diagnostics")
				return
			end

			local diags = {}
			local lines = vim.split(stdout, "\n")
			local i = 1
			while i <= #lines do
				local severity, msg, tag = lines[i]:match("^(%u+)%s+(.-)%s+%[([%w%-]+)%]$")
				if severity and tag then
					local file, lnum, col
					for j = i + 1, math.min(i + 3, #lines) do
						file, lnum, col = lines[j]:match("%-%-?>%s+(.+):(%d+):(%d+)")
						if file then
							i = j
							break
						end
					end
					if file then
						if not vim.startswith(file, "/") then
							file = root .. "/" .. file
						end
						diags[#diags + 1] = {
							tag = tag,
							severity = severity,
							message = msg,
							filename = file,
							lnum = tonumber(lnum),
							col = tonumber(col),
						}
					end
				end
				i = i + 1
			end

			if #diags == 0 then
				Snacks.notify.info("No pyrefly diagnostics")
				return
			end

			local by_tag = {}
			for _, d in ipairs(diags) do
				if not by_tag[d.tag] then
					by_tag[d.tag] = { tag = d.tag, count = 0, diags = {} }
				end
				by_tag[d.tag].count = by_tag[d.tag].count + 1
				by_tag[d.tag].diags[#by_tag[d.tag].diags + 1] = d
			end

			local items = vim.tbl_values(by_tag)
			table.sort(items, function(a, b)
				return a.count > b.count
			end)
			for _, item in ipairs(items) do
				item.text = ("%s %d"):format(item.tag, item.count)
			end

			Snacks.picker({
				title = "Pyrefly Diagnostics",
				items = items,
				layout = { preset = "select" },
				format = function(item)
					return {
						{ ("%4d"):format(item.count), "Number" },
						{ "  " },
						{ item.tag, "DiagnosticError" },
					}
				end,
				confirm = function(picker, _)
					picker:close()
					local selected = picker:selected({ fallback = true })
					local qf = {}
					for _, sel in ipairs(selected) do
						for _, d in ipairs(sel.diags) do
							qf[#qf + 1] = {
								filename = d.filename,
								lnum = d.lnum,
								col = d.col,
								text = ("[%s] %s"):format(d.tag, d.message),
								type = d.severity == "ERROR" and "E" or "W",
							}
						end
					end
					local tags = vim.tbl_map(function(s)
						return s.tag
					end, selected)
					vim.fn.setqflist({}, " ", {
						title = "pyrefly: " .. table.concat(tags, ", "),
						items = qf,
					})
					vim.cmd("Trouble qflist open")
				end,
			})
		end)
	end)
end, { desc = "Pyrefly diagnostics by tag" })
