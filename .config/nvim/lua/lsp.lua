-- Highlight every other use of the symbol under the cursor, cleared as soon as
-- the cursor moves. Driven by 'updatetime' (set in init.lua).
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or not client:supports_method("textDocument/documentHighlight") then
			return
		end

		local group = vim.api.nvim_create_augroup("lsp_doc_highlight_" .. args.buf, { clear = true })
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = group,
			buffer = args.buf,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			group = group,
			buffer = args.buf,
			callback = vim.lsp.buf.clear_references,
		})
	end,
})

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
			-- checkOnSave is a boolean; the checker itself is set via `check`.
			checkOnSave = true,
			check = {
				command = "clippy",
			},
		},
	},
})

-- vtsls fires this command after organising imports; stub it out so the
-- unhandled-command error is suppressed.
vim.lsp.commands["_typescript.didOrganizeImports"] = function() end

vim.lsp.config("vtsls", {
	capabilities = {
		textDocument = {
			completion = {
				completionItem = {
					insertReplaceSupport = false,
				},
			},
		},
	},
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
