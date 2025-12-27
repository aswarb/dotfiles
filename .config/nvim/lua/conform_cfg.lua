require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		-- Conform will run multiple formatters sequentially
		python = { "black" },
		-- You can customize some of the format options for the filetype (:help conform.format)
		rust = { "rustfmt", lsp_format = "fallback" },
		-- Conform will run the first available formatter
		javascript = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		vue = { "prettierd", "prettier", stop_after_first = true },
		react = { "prettierd", "prettier", stop_after_first = true },
		go = { "gofmt" },
		toml = { "taplo" },
	},
	formatters = {
		gofmt = { exe = "gofmt", args = {}, stdin = true },
	},
})

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.range > 0 then
		-- Format only the selected lines if a range is given
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, 0 },
		}
	end
	require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })
