-- Leaders must be set before anything defines a mapping.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = true

-- Persist undo to disk so undotree spans sessions, not just this one.
vim.o.undofile = true

-- Case-insensitive search unless the pattern contains a capital.
vim.o.ignorecase = true
vim.o.smartcase = true

-- Prompt to save on quit rather than erroring with E37.
vim.o.confirm = true

-- Keep context around the cursor rather than letting it hit the screen edge.
vim.o.scrolloff = 8

-- New windows open below and to the right, so existing content stays put.
vim.o.splitbelow = true
vim.o.splitright = true

vim.o.smartindent = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- Open files fully expanded; folds are still there on demand (za/zc/zR/zM).
vim.o.foldlevelstart = 99

-- Drives the CursorHold that highlights other uses of the symbol under the
-- cursor (see lsp.lua). Default 4000ms is far too slow to feel responsive.
vim.o.updatetime = 300

vim.diagnostic.config({
	virtual_text = { virt_text_pos = "eol" },
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

-- Yank over OSC 52 so copies reach the host clipboard through SSH; paste stays
-- local via wl-paste.
local osc52 = require("vim.ui.clipboard.osc52")
vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = osc52.copy("+"),
		["*"] = osc52.copy("*"),
	},
	paste = {
		["+"] = function()
			return vim.fn.systemlist("wl-paste --no-newline")
		end,
		["*"] = function()
			return vim.fn.systemlist("wl-paste --no-newline --primary")
		end,
	},
}

-- Window navigation. This takes <C-l>, whose default job (clearing search
-- highlight) moves to <Esc>.
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<Bar>diffupdate<CR>", { desc = "Clear search highlight" })

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+y$', { desc = "Yank line-end to clipboard" })

-- l: lsp
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Goto definition" })

vim.keymap.set("n", "<leader>le", function()
	vim.diagnostic.open_float({ border = "rounded", source = true, scope = "cursor" })
end, { desc = "Show diagnostic" })

vim.keymap.set("n", "<leader>la", function()
	vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
end, { desc = "Source actions" })

-- t: toggles. Inlay hints off by default; they are visually heavy.
vim.keymap.set("n", "<leader>th", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

-- Vimtex
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_compiler_latexmk = {
	aux_dir = "",
	out_dir = "",
	callback = 1,
	continuous = 1,
	executable = "latexmk",
	hooks = {},
	options = {
		"-verbose",
		"-file-line-error",
		"-synctex=1",
		"-interaction=nonstopmode",
		"-shell-escape",
	},
}

-- markdown-preview: open the rendered page in a new Firefox tab.
vim.cmd([[
function OpenMarkdownPreview (url)
  execute "firefox --new-tab " . a:url
endfunction
]])
vim.g.mkdp_browserfunc = "OpenMarkdownPreview"

require("quickfix")

require("cheatsheet")
vim.keymap.set("n", "<leader>?", "<Cmd>Cheatsheet<CR>", { desc = "Keymap cheatsheet" })

require("plugins")
require("cynored_cfg")
vim.cmd.colorscheme("kanagawa")
require("mason_cfg")
require("conform_cfg")
require("mason-conform_cfg")
require("lsp")
require("telescope_cfg")
require("lualine_cfg")
require("blink-cmp_cfg")
require("keybinds")
require("marks_cfg")
require("nvim-colorizer_cfg")
require("treesitter_cfg")
