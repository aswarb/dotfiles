vim.diagnostic.config({
  virtual_text = true,  -- Show diagnostics as virtual text
  signs = true,         -- Show signs in the gutter
  underline = true,     -- Underline problematic code
  update_in_insert = false, -- Update diagnostics in insert mode
  severity_sort = true, -- Sort diagnostics by severity
})

vim.o.wrap = true
vim.wo.wrap = true

