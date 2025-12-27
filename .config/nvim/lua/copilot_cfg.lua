local log = require("plenary.log").new({ ... })

require("copilot").setup({
	panel = {
		enabled = false,
		auto_refresh = false,
		keymap = {
			jump_prev = "[[",
			jump_next = "]]",
			accept = "<CR>",
			refresh = "gr",
			open = "<M-CR>",
		},
		layout = {
			position = "bottom", -- | top | left | right | bottom |
			ratio = 0.2,
		},
	},
	suggestion = {
		enabled = false,
		auto_trigger = false,
		hide_during_completion = false,
		debounce = 75,
		trigger_on_accept = true,
		keymap = {
			accept = "<M-l>",
			accept_word = false,
			accept_line = false,
			next = "<M-n>",
			prev = "<M-p>",
			dismiss = "<C-q>",
		},
	},
	nes = {
		enabled = false, -- requires copilot-lsp as a dependency
		auto_trigger = false,
		keymap = {
			accept_and_goto = false,
			accept = false,
			dismiss = false,
		},
	},
	auth_provider_url = nil, -- URL to authentication provider, if not "https://github.com/"
	logger = {
		file = vim.fn.stdpath("log") .. "/copilot-lua.log",
		file_log_level = vim.log.levels.ERROR, -- Changed from OFF
		print_log_level = vim.log.levels.ERROR, -- Changed to DEBUG
		trace_lsp = "off", -- Changed from "off"
		trace_lsp_progress = true, -- Changed to true
		log_lsp_messages = true, -- Changed to true
	},
	copilot_node_command = "node", -- Node.js version must be > 22
	workspace_folders = {},
	copilot_model = "",
	disable_limit_reached_message = false, -- Set to `true` to suppress completion limit reached popup
	root_dir = function()
		return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
	end,
	should_attach = function(bufnr, buftype)
		if not vim.bo[bufnr].buflisted then
			log.debug("not attaching, buffer is not 'buflisted'")
			return false
		end
		if vim.bo[bufnr].buftype ~= "" then
			log.debug("not attaching, buffer 'buftype' is " .. vim.bo[bufnr].buftype)
			return false
		end
		return true
	end,
	server = {
		type = "nodejs", -- "nodejs" | "binary"
		custom_server_filepath = nil,
	},
	server_opts_overrides = {},
})

vim.keymap.set("n", "<leader>cs", function()
	log.debug("trying suggestion")
	require("copilot.suggestion").next()
end, { desc = "Trigger Copilot suggestion" })
