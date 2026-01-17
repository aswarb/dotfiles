local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>lg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fm", builtin.marks, {})
vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
vim.keymap.set("n", "<leader>bb", builtin.buffers, {})
vim.keymap.set("n", "<leader>ht", builtin.help_tags, {})
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>gr", builtin.lsp_references, { noremap = true, silent = true })

-- Quickfix navigation
vim.keymap.set("n", "<leader>co", ":copen<CR>", { noremap = true, silent = true }) -- open quickfix
vim.keymap.set("n", "<leader>cc", ":cclose<CR>", { noremap = true, silent = true }) -- close quickfix
vim.keymap.set("n", "<C-n>", ":cnext<CR>", { noremap = true, silent = true }) -- next item
vim.keymap.set("n", "<C-p>", ":cprev<CR>", { noremap = true, silent = true })

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local themes = require("telescope.themes")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")

-- This is your opts table
require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_to_qflist + actions.open_qflist,
			},
			n = {
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_to_qflist + actions.open_qflist,
			},
		},
	},
	pickers = {
		marks = {
			mappings = {
				i = {
					["<C-d>"] = function(prompt_bufnr)
						local picker = action_state.get_current_picker(prompt_bufnr)
						local selections = picker:get_multi_selection()

						actions.close(prompt_bufnr)

						-- If nothing selected with Tab, delete the one under cursor
						if #selections == 0 then
							local selection = action_state.get_selected_entry()
							local mark = selection.display:sub(1, 1)
							-- Only delete if it's a valid user mark (a-z, A-Z, 0-9)
							if mark:match("[a-zA-Z0-9]") then
								vim.cmd("delmarks " .. mark)
							end
						else
							-- Delete selected marks, but only valid ones
							local marks_to_delete = {}
							for _, selection in ipairs(selections) do
								local mark = selection.display:match("^(%S)")
								-- Only include user-settable marks
								if mark and mark:match("[a-zA-Z0-9]") then
									table.insert(marks_to_delete, mark)
								end
							end

							if #marks_to_delete > 0 then
								vim.cmd("delmarks " .. table.concat(marks_to_delete, ""))
							end
						end
					end,
				},
				n = {
					["<C-d>"] = function(prompt_bufnr)
						local picker = action_state.get_current_picker(prompt_bufnr)
						local selections = picker:get_multi_selection()

						actions.close(prompt_bufnr)

						-- If nothing selected with Tab, delete the one under cursor
						if #selections == 0 then
							local selection = action_state.get_selected_entry()
							local mark = selection.display:sub(1, 1)
							-- Only delete if it's a valid user mark (a-z, A-Z, 0-9)
							if mark:match("[a-zA-Z0-9]") then
								vim.cmd("delmarks " .. mark)
							end
						else
							-- Delete selected marks, but only valid ones
							local marks_to_delete = {}
							for _, selection in ipairs(selections) do
								local mark = selection.display:match("^(%S)")
								-- Only include user-settable marks
								if mark and mark:match("[a-zA-Z0-9]") then
									table.insert(marks_to_delete, mark)
								end
							end

							if #marks_to_delete > 0 then
								vim.cmd("delmarks " .. table.concat(marks_to_delete, ""))
							end
						end
					end,
				},
			},
		},
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
})
-- To get ui-select loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")
