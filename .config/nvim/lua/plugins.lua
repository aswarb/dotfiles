-- Plugin management via Neovim 0.12's builtin `vim.pack`.
-- Replaces the old packer.nvim setup (lua/packer_cfg.lua).

local gh = function(x)
	return "https://github.com/" .. x
end

-- Build steps that packer ran via its `run` key.
local builds = {
	["blink.cmp"] = { "cargo", "build", "--release" },
	["markdown-preview.nvim"] = { "sh", "-c", "cd app && npm install" },
}

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if kind ~= "install" and kind ~= "update" then
			return
		end

		local cmd = builds[name]
		if cmd then
			vim.system(cmd, { cwd = ev.data.path }):wait()
		end

		if name == "nvim-treesitter" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			pcall(function()
				require("nvim-treesitter").update()
			end)
		end
	end,
})

vim.pack.add({
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },

	{ src = gh("nvim-lua/plenary.nvim") },
	{ src = gh("nvim-telescope/telescope.nvim") },
	{ src = gh("nvim-telescope/telescope-ui-select.nvim") },
	{ src = gh("nvim-tree/nvim-web-devicons") },

	{ src = gh("williamboman/mason.nvim") },
	{ src = gh("williamboman/mason-lspconfig.nvim") },
	{ src = gh("neovim/nvim-lspconfig") },

	{ src = gh("chentoast/marks.nvim") },
	{ src = gh("nvim-lualine/lualine.nvim") },
	{ src = gh("NvChad/nvim-colorizer.lua") },
	{ src = gh("rebelot/kanagawa.nvim") },

	{ src = gh("lervag/vimtex") },
	{ src = gh("mbbill/undotree") },

	{ src = gh("stevearc/conform.nvim") },
	{ src = gh("zapling/mason-conform.nvim") },

	{ src = gh("sindrets/diffview.nvim") },
	{ src = gh("tpope/vim-fugitive") },

	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1") },
	-- VSCode-style snippet library; blink's snippet source scans the
	-- runtimepath for its package.json, so no further wiring is needed.
	{ src = gh("rafamadriz/friendly-snippets") },
})

-- markdown-preview was `opt` + `ft = { "markdown" }` under packer, so keep it
-- off the runtime path until a markdown buffer appears.
vim.g.mkdp_filetypes = { "markdown" }
vim.pack.add({ gh("iamcco/markdown-preview.nvim") }, { load = false })
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	once = true,
	callback = function()
		vim.cmd.packadd("markdown-preview.nvim")
	end,
})
