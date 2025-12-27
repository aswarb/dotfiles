-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
	})
	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({ "nvim-telescope/telescope-ui-select.nvim" })

	use("navarasu/onedark.nvim")
	use("rose-pine/neovim")
	use("everviolet/nvim")
	use({
		"nvim-tree/nvim-tree.lua",
		requires = {
			"nvim-tree/nvim-web-devicons", -- optional
		},
	})
	use("ThePrimeagen/vim-be-good")

	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use("neovim/nvim-lspconfig")

	use("ms-jpq/coq_nvim")
	use("ms-jpq/coq.artifacts")
	use("ms-jpq/coq.thirdparty")
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
	})
	-- use("folke/tokyonight.nvim")
	use("sainnhe/gruvbox-material")
	use("shaunsingh/nord.nvim")
	use("NvChad/nvim-colorizer.lua")
	use({ "akinsho/bufferline.nvim", tag = "*", requires = "nvim-tree/nvim-web-devicons" })
	-- use "Bekaboo/dropbar.nvim"

	use({
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	})

	use("David-Kunz/gen.nvim")

	-- use({ "mhartington/formatter.nvim" })

	use("lervag/vimtex")

	use("mbbill/undotree")
	use("nvim-lua/plenary.nvim")
	use({
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use("rebelot/kanagawa.nvim")

	use({
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup()
		end,
	})
	use("zapling/mason-conform.nvim")

	use({
		"zbirenbaum/copilot.lua",
		requires = { "copilotlsp-nvim/copilot-lsp" },
		dependencies = {
			"nvim-lua/plenary.nvim", -- Add this dependency
		},
	})
	use({
		"CopilotC-Nvim/CopilotChat.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
	})
end)
