-- LazyVim loads this before initializing plugins.
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
vim.g.lazyvim_python_lsp = 'basedpyright'
vim.g.lazyvim_python_ruff = 'ruff'

-- The Python provider is isolated from system Python (PEP 668 friendly).
local python = vim.fn.expand('~/.venvs/ansible-dev/bin/python')
if vim.fn.executable(python) == 1 then
  vim.g.python3_host_prog = python
end

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 6
vim.opt.signcolumn = 'yes'
vim.opt.list = true
vim.opt.listchars = { tab = '→ ', trail = '·', nbsp = '␣' }
vim.opt.colorcolumn = '100'
vim.opt.termguicolors = true
