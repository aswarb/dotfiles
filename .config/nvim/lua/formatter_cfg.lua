-- Utilities for creating configurations
local util = require("formatter.util")

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup({
	-- Enable or disable logging
	logging = true,
	-- Set the log level
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = {
		-- Formatter configurations for filetype "lua" go here
		-- and will be executed in order
		lua = { require("formatter.filetypes.lua").stylua },
		python = { require("formatter.filetypes.python").black },
		xml = { require("formatter.filetypes.xml").xmlformatter },
		html = { require("formatter.filetypes.html").prettier },
		css = { require("formatter.filetypes.css").prettier },
		json = { require("formatter.filetypes.json").prettier },
		markdown = { require("formatter.filetypes.markdown").prettier },
		javascript = { require("formatter.filetypes.javascript").prettier },
		typescript = { require("formatter.filetypes.typescript").prettier },
		yaml = { require("formatter.filetypes.yaml").prettier },
		c = { require("formatter.filetypes.c").clangformat },
		cs = { require("formatter.filetypes.cs").clangformat },
		cpp = { require("formatter.filetypes.cpp").clangformat },
		java = { require("formatter.filetypes.java").clangformat },
		sh = { require("formatter.filetypes.sh").shfmt },
		latex = { require("formatter.filetypes.latex").latexindent },
		cmake = { require("formatter.filetypes.cmake").cmakelang },
	},
	["*"] = {
		-- "formatter.filetypes.any" defines default configurations for any
		-- filetype
		require("formatter.filetypes.any").remove_trailing_whitespace,
	},
})
