-- Lists the keymaps this config defines, read from Neovim at runtime so the
-- list is what is actually bound rather than what the source files say.
--
-- Runtime maps need filtering: plugin setup() calls made from this config
-- inherit its script id, so marks.nvim's default_mappings would otherwise
-- show up alongside ours. Leader-prefixed maps plus EXTRA are the ours.

-- Non-leader maps we still want listed, and the group they belong to.
local EXTRA = {
	["<C-N>"] = "QUICKFIX",
	["<C-P>"] = "QUICKFIX",
	["<C-H>"] = "WINDOWS",
	["<C-J>"] = "WINDOWS",
	["<C-K>"] = "WINDOWS",
	["<C-L>"] = "WINDOWS",
	["<Esc>"] = "WINDOWS",
}

-- One letter, one meaning. Order here is the order sections are printed.
local GROUPS = {
	{ key = "f", title = "FIND" },
	{ key = "l", title = "LSP" },
	{ key = "g", title = "GIT" },
	{ key = "q", title = "QUICKFIX" },
	{ key = "t", title = "TOGGLE" },
	{ key = "y", title = "CLIPBOARD" },
	{ key = "Y", title = "CLIPBOARD" },
	{ key = "?", title = "META" },
}

local TITLES = {}
for _, g in ipairs(GROUPS) do
	TITLES[g.key] = g.title
end

-- Built-in keys worth remembering. Most are commands or motions rather than
-- mappings, so they cannot be discovered at runtime. Edit freely.
local REFERENCE = {
	{
		title = "BUFFERS (built-in)",
		items = {
			{ "]b  [b", "Next / previous buffer", "nvim 0.11+" },
			{ "]B  [B", "Last / first buffer", "nvim 0.11+" },
			{ "<C-^>", "Toggle alternate buffer" },
			{ ":b {n}", "Jump to buffer number (shown in tabline)" },
			{ ":b {name}", "Jump by name, <Tab> completes" },
			{ ":ls", "List buffers" },
			{ ":bd", "Delete buffer" },
		},
	},
	{
		title = "MARKS (built-in)",
		items = {
			{ "ma", "Set mark a, local to this file" },
			{ "mA", "Set mark A, global across files" },
			{ "'a   `a", "Jump to mark line / exact position" },
			{ "''   ``", "Back to position before last jump" },
			{ "'.", "Position of last change" },
			{ "'^", "Position of last insert" },
			{ ":marks", "List all marks" },
			{ ":delmarks a", "Delete mark a" },
		},
	},
	{
		title = "MARKS (marks.nvim)",
		items = {
			{ "m;", "Toggle mark on this line" },
			{ "m,", "Set next available mark" },
			{ "m]  m[", "Next / previous mark" },
			{ "m:", "Preview mark" },
			{ "m0 - m9", "Set bookmark in group 0-9" },
			{ "m}  m{", "Next / previous bookmark" },
			{ "dm{a}", "Delete mark a" },
			{ "dm-", "Delete all marks on this line" },
			{ "dm<Space>", "Delete all marks in this buffer" },
		},
	},
	{
		title = "WINDOWS (built-in)",
		items = {
			{ "<C-w>s  <C-w>v", "Split horizontal / vertical" },
			{ "<C-w>H J K L", "Relocate window to far left/bottom/top/right" },
			{ "<C-w>x", "Swap this window with the next" },
			{ "<C-w>=", "Equalise all window sizes" },
			{ "<C-w>_  <C-w>|", "Maximise height / width" },
			{ "<C-w>+ - < >", "Resize by one row / column" },
			{ "<C-w>o", "Close every window but this one" },
			{ "<C-w>c", "Close this window" },
			{ "<C-w>p", "Jump to previously focused window" },
			{ "<C-w>T", "Move this window into its own tab" },
		},
	},
	{
		title = "JUMPS (built-in)",
		items = {
			{ "<C-o>  <C-i>", "Jumplist back / forward, crosses files" },
			{ "g;   g,", "Changelist older / newer edit" },
			{ "gf", "Open file under cursor" },
			{ "gi", "Resume last insert position" },
		},
	},
}

local MODES = { "n", "v", "x", "i", "o", "t" }

local function config_scripts()
	local cfg = vim.fn.stdpath("config")
	local out = {}
	for _, s in ipairs(vim.fn.getscriptinfo()) do
		if s.name:sub(1, #cfg) == cfg then
			out[s.sid] = true
		end
	end
	return out
end

local function scan()
	local from_config = config_scripts()
	local leader = vim.g.mapleader or "\\"
	local found, seen = {}, {}

	for _, mode in ipairs(MODES) do
		for _, k in ipairs(vim.api.nvim_get_keymap(mode)) do
			local is_ours = k.lhs:sub(1, #leader) == leader or EXTRA[k.lhs]

			if is_ours and from_config[k.sid] then
				-- The same lhs in several modes is one entry, modes joined.
				local key = k.lhs
				if seen[key] then
					seen[key].mode = seen[key].mode .. "," .. mode
				else
					local suffix = k.lhs:sub(#leader + 1)
					local entry = {
						lhs = (k.lhs:gsub("^" .. vim.pesc(leader), "<leader>")),
						desc = k.desc or "",
						mode = mode,
						group = EXTRA[k.lhs] or TITLES[suffix:sub(1, 1)] or "OTHER",
					}
					seen[key] = entry
					found[#found + 1] = entry
				end
			end
		end
	end

	table.sort(found, function(a, b)
		return a.lhs:lower() < b.lhs:lower()
	end)

	return found
end

local function build()
	local by_group = {}
	for _, m in ipairs(scan()) do
		by_group[m.group] = by_group[m.group] or {}
		table.insert(by_group[m.group], m)
	end

	-- Declared order first, then anything unclassified.
	local order, listed = {}, {}
	for _, g in ipairs(GROUPS) do
		if by_group[g.title] and not listed[g.title] then
			listed[g.title] = true
			order[#order + 1] = g.title
		end
	end
	for _, name in ipairs({ "QUICKFIX", "WINDOWS", "OTHER" }) do
		if by_group[name] and not listed[name] then
			listed[name] = true
			order[#order + 1] = name
		end
	end

	local lines = { "keymaps    (/ to search, q to close)" }
	for _, title in ipairs(order) do
		lines[#lines + 1] = ""
		lines[#lines + 1] = title
		for _, m in ipairs(by_group[title]) do
			lines[#lines + 1] = string.format("  %-6s %-14s %s", m.mode, m.lhs, m.desc)
		end
	end

	-- Built-in reference, appended after everything this config defines.
	for _, section in ipairs(REFERENCE) do
		lines[#lines + 1] = ""
		lines[#lines + 1] = section.title
		for _, item in ipairs(section.items) do
			local keys, desc, note = item[1], item[2], item[3]
			lines[#lines + 1] = string.format(
				"  %-6s %-14s %s%s",
				"",
				keys,
				desc,
				note and ("  [" .. note .. "]") or ""
			)
		end
	end

	return lines
end

local function open()
	vim.cmd("tabnew")
	local buf = vim.api.nvim_get_current_buf()

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, build())
	vim.api.nvim_buf_set_name(buf, "cheatsheet")

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "cheatsheet"

	vim.keymap.set("n", "q", "<Cmd>tabclose<CR>", { buffer = buf, nowait = true })
end

vim.api.nvim_create_user_command("Cheatsheet", open, { desc = "Show this config's keymaps" })

return { open = open, scan = scan }
