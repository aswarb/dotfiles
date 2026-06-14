vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

vim.o.wrap = true
vim.wo.wrap = true

vim.lsp.config("gopls", {
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
		},
	},
})

vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			checkOnSave = {
				command = "clippy",
			},
		},
	},
})

vim.lsp.config("vtsls", {
	settings = {
		typescript = {
			preferences = {
				importModuleSpecifier = "non-relative",
			},
		},
		javascript = {
			preferences = {
				importModuleSpecifier = "non-relative",
			},
		},
	},
})
