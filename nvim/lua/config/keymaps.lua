-- Helpful when cleaning up YAML before committing.
vim.keymap.set('n', '<leader>cw', [[:%s/\s\+$//e<CR>]], {
  desc = 'Remove trailing whitespace in current buffer',
})
