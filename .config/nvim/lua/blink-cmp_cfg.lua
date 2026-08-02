require("blink.cmp").setup({
	keymap = {
		preset = "enter",
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },
		["<C-k>"] = { "scroll_documentation_up", "fallback" },
		["<C-j>"] = { "scroll_documentation_down", "fallback" },
		["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
	},
	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 150 },
		menu = {
			draw = {
				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
					{ "source_name" },
				},
			},
		},
		list = {
			selection = {
				preselect = false,
				auto_insert = false,
			},
		},
		ghost_text = { enabled = true },
		accept = {
			auto_brackets = { enabled = true },
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		providers = {
			snippets = { score_offset = -4 },
			buffer = { score_offset = -5 },
		},
	},
	signature = {
		enabled = true,
		trigger = { enabled = true },
	},
	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
})
