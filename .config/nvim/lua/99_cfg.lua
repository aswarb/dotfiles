local _99 = require("99")

-- For logging that is to a file if you wish to trace through requests
-- For reporting bugs, do not rely solely on this; use the provided logging
-- mechanisms within 99. This logger is more for debugging purposes.
_99.setup({
	provider = _99.OpenCodeProvider,
	model = "github-copilot/gpt-4.1",
	logger = {
		level = _99.DEBUG,
		path = "/tmp/99.debug",
		print_on_error = true,
	},

	-- Completions: #rules and @files in the prompt buffer
	completion = {
		-- Cursor rules temporarily disabled until usage is clarified.
		-- Cursor rules may need to be applied differently if within application rules.
		-- cursor_rules = "<custom path to cursor rules>"

		-- A list of full paths to SKILL.md for custom rules.
		-- Format: /path/to/dir/<skill_name>/SKILL.md
		custom_rules = {
			"/home/aos/.config/opencode/skills/neovim/SKILL.md",
			"/home/aos/.config/opencode/skills/sql/SKILL.md",
			"/home/aos/.config/opencode/skills/redis/SKILL.md",
			"/home/aos/.config/opencode/skills/react/SKILL.md",
			"/home/aos/.config/opencode/skills/postgres/SKILL.md",
			"/home/aos/.config/opencode/skills/nextjs/SKILL.md",
			"/home/aos/.config/opencode/skills/lua/SKILL.md",
			"/home/aos/.config/opencode/skills/kubernetes/SKILL.md",
			"/home/aos/.config/opencode/skills/jsx/SKILL.md",
			"/home/aos/.config/opencode/skills/javascript/SKILL.md",
			"/home/aos/.config/opencode/skills/html/SKILL.md",
			"/home/aos/.config/opencode/skills/docker/SKILL.md",
			"/home/aos/.config/opencode/skills/aws-sdk/SKILL.md",
			"/home/aos/.config/opencode/skills/typescript/SKILL.md",
			"/home/aos/.config/opencode/skills/bash/SKILL.md",
			"/home/aos/.config/opencode/skills/python/SKILL.md",
		},

		-- Configure @file completion (fields optional, sensible defaults set)
		files = {
			enabled = true,
			-- max_file_size = 102400,     -- bytes, skip files larger than this
			-- max_files = 5000,           -- cap on total discovered files
			exclude = {
				".env",
				".env.*",
				"node_modules",
				".git",
				"*.lock",
				".bun/*",
				".cache/*",
				".atlas/*",
				".aws/*",
			},
		},

		-- Only cmp is currently supported for autocomplete source
		source = "cmp",
	},

	-- WARNING: Changing cwd can break automatic md_files finding.
	-- md_files auto add AGENT.md at the project or parent directory.
	md_files = {
		"AGENT.md",
	},
})

-- Only allow visual mappings in `v` mode so you do not trigger on the wrong selection
-- (The active selection is always used, so keeping these visual-only avoids mistakes.)
-- It is a good idea to assert mode in your implementation for correctness.
vim.keymap.set("v", "<leader>v9", function()
	_99.visual()
end, { noremap = true })

vim.keymap.set("v", "<leader>s9", function()
	_99.stop_all_requests()
end, { noremap = true })

vim.keymap.set("v", "<leader>c9", function()
	_99.stop_all_requests()
end, { noremap = true })
