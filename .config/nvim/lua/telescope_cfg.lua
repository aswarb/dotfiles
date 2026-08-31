local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- f: find. Anything that opens a picker lives here.
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Git files" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Marks" })
vim.keymap.set("n", "<leader>fl", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume last picker" })
vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Symbols in file" })
vim.keymap.set("n", "<leader>fS", builtin.lsp_dynamic_workspace_symbols, { desc = "Symbols in project" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Workspace diagnostics" })

-- g: git. Fugitive and diffview live in keybinds.lua; these are the pickers.
-- <Tab> in git_status stages/unstages the file under the cursor.
vim.keymap.set("n", "<leader>gd", builtin.git_status, { desc = "Changed files" })
vim.keymap.set("n", "<leader>gl", builtin.git_commits, { desc = "Commit log" })
vim.keymap.set("n", "<leader>gh", builtin.git_bcommits, { desc = "History of this file" })
vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Branches" })

-- l: lsp. Pickers, but semantically LSP queries rather than file search.
vim.keymap.set("n", "<leader>lr", builtin.lsp_references, { silent = true, desc = "References" })
vim.keymap.set("n", "<leader>li", builtin.lsp_incoming_calls, { desc = "Incoming calls" })
vim.keymap.set("n", "<leader>lo", builtin.lsp_outgoing_calls, { desc = "Outgoing calls" })

-- Delete the mark under the cursor, or every Tab-selected mark.
local function delete_marks(prompt_bufnr)
	local picker = action_state.get_current_picker(prompt_bufnr)
	local selections = picker:get_multi_selection()

	actions.close(prompt_bufnr)

	local marks = {}
	if #selections == 0 then
		local entry = action_state.get_selected_entry()
		marks[1] = entry and entry.display:sub(1, 1)
	else
		for _, selection in ipairs(selections) do
			marks[#marks + 1] = selection.display:match("^(%S)")
		end
	end

	-- Only user-settable marks can be deleted; delmarks errors on the rest.
	local deletable = vim.tbl_filter(function(mark)
		return mark and mark:match("^[a-zA-Z0-9]$") ~= nil
	end, marks)

	if #deletable > 0 then
		vim.cmd("delmarks " .. table.concat(deletable, ""))
	end
end

local to_qflist = {
	["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
	["<M-q>"] = actions.send_to_qflist + actions.open_qflist,
}

require("telescope").setup({
	defaults = {
		mappings = { i = to_qflist, n = to_qflist },
	},
	pickers = {
		marks = {
			mappings = {
				i = { ["<C-d>"] = delete_marks },
				n = { ["<C-d>"] = delete_marks },
			},
		},
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
})

require("telescope").load_extension("ui-select")
