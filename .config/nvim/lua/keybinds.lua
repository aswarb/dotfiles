vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle)

-- Fugitive keybindings
vim.keymap.set('n', '<leader>gs', ':Git<CR>', { noremap = true, silent = true })  -- Git status
vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<CR>', { noremap = true, silent = true })  -- Diff split

-- Diffview for conflicts
vim.keymap.set('n', '<leader>gc', ':DiffviewOpen<CR>', { noremap = true, silent = true })  -- Open diffview
vim.keymap.set('n', '<leader>gC', ':DiffviewClose<CR>', { noremap = true, silent = true })  -- Close diffview
