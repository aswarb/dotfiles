require('blink.cmp').setup({
    keymap = { preset = 'super-tab' },
    completion = {
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
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    fuzzy = {
        implementation = 'prefer_rust_with_warning',
    },
})
