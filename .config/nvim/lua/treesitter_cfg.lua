require("nvim-treesitter").setup({
	-- optional: custom install directory
	-- install_dir = ...
})

-- Install parsers (replaces ensure_installed)
require("nvim-treesitter").install({
	"c",
	"lua",
	"vim",
	"vimdoc",
	"query",
	"typescript",
	"tsx",
	"javascript",
	"bash",
	"sql",
	"rust",
	"go",
})

-- Highlighting is now built into neovim, enable it per filetype
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "*" },
	callback = function()
		pcall(vim.treesitter.start)
	end,
})
