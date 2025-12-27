local function my_on_attach(bufnr)
    local api = require "nvim-tree.api"

    local function opts(desc)
	return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- default mappings
    -- api.config.mappings.default_on_attach(bufnr)

    -- custom mappings
    vim.keymap.set('n', '?',     		api.tree.toggle_help,	opts('Help'))
    vim.keymap.set('n', '<leader>tt',	api.tree.toggle,	{})
    vim.keymap.set('n', '<leader>ts',	api.tree.search_node,	opts('Search'))


end

-- pass to setup along with your other options
return require("nvim-tree").setup {
    on_attach = my_on_attach(),
}
