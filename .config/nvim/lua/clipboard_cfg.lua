vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = function() return vim.fn.systemlist('wl-paste --no-newline') end,
    ['*'] = function() return vim.fn.systemlist('wl-paste --no-newline --primary') end,
  },
}

vim.keymap.set({'n', 'v'}, '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+y$')
