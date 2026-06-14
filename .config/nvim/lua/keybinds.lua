vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle)

-- Fugitive keybindings
vim.keymap.set('n', '<leader>gs', ':Git<CR>', { noremap = true, silent = true })  -- Git status
vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<CR>', { noremap = true, silent = true })  -- Diff split

-- Diffview for conflicts
vim.keymap.set('n', '<leader>gc', ':DiffviewOpen<CR>', { noremap = true, silent = true })  -- Open diffview
vim.keymap.set('n', '<leader>gC', ':DiffviewClose<CR>', { noremap = true, silent = true })  -- Close diffview



vim.ui.select = function(items, opts, on_choice)
    local format = opts.format_item or tostring
    local formatted = vim.tbl_map(format, items)
    _G._ui_select_items = formatted

    local result = vim.fn.input({
        prompt = (opts.prompt or 'Select') .. ': ',
        completion = 'customlist,v:lua._ui_select_complete',
    })

    _G._ui_select_items = nil

    if result == '' then
        on_choice(nil, nil)
        return
    end

    for i, item in ipairs(formatted) do
        if item == result then
            on_choice(items[i], i)
            return
        end
    end
    on_choice(nil, nil)
end

vim.lsp.commands["_typescript.didOrganizeImports"] = function() end
function _G._ui_select_complete(lead, _, _)
    if lead == '' then
        return _G._ui_select_items
    end
    return vim.tbl_filter(function(item)
        return item:find(lead, 1, true) ~= nil
    end, _G._ui_select_items)
end

vim.keymap.set('n', '<leader>ia', function()
    vim.lsp.buf.code_action({
        context = {
            only = { 'source' },
            diagnostics = {},
        }
    })
end, { desc = 'Source actions' })
