-- t: toggles
vim.keymap.set("n", "<leader>tu", vim.cmd.UndotreeToggle, { desc = "Toggle undotree" })

-- Fugitive
vim.keymap.set("n", "<leader>gs", "<Cmd>Git<CR>", { silent = true, desc = "Git status" })
vim.keymap.set("n", "<leader>gv", "<Cmd>Gvdiffsplit<CR>", { silent = true, desc = "Git diff split" })

-- Diffview, for conflicts
vim.keymap.set("n", "<leader>gc", "<Cmd>DiffviewOpen<CR>", { silent = true, desc = "Open diffview" })
vim.keymap.set("n", "<leader>gC", "<Cmd>DiffviewClose<CR>", { silent = true, desc = "Close diffview" })
