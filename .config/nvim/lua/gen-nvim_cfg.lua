
require('gen').model = 'codegemma:7b'

require('gen').prompts['Elaborate_Text'] = {
  prompt = "Elaborate the following text:\n$text",
  replace = true
}
require('gen').prompts['Fix_Code'] = {
  prompt = "Fix the following code. Only ouput the result in format ```$filetype\n...\n```:\n```$filetype\n$text\n```",
  replace = true,
  extract = "```$filetype\n(.-)```"
}

vim.keymap.set('v', '<leader>gg', ':Gen<CR>')
vim.keymap.set('n', '<leader>gg', ':Gen<CR>')


require('gen')
