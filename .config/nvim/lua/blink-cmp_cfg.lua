require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	completion = {
		accept = {
			auto_brackets = { enabled = true },
		},
		list = {
			selection = {
				preselect = false,
				auto_insert = false,
			},
		},
		documentation = { auto_show = false },
		ghost_text = { enabled = true },
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		providers = {
			lsp = {
				--async = true,
				transform_items = function(_, items)
    local f = io.open("/tmp/cmp_debug.txt", "a")
    if f then
        f:write(vim.inspect(items[1]))
        f:close()
    end
    return items
end,
			},
		},
	},
	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
})
