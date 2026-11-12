local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local output = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error('Unable to bootstrap lazy.nvim:\n' .. output)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
    -- Extras are explicitly imported so all colleagues get the same feature set.
    { import = 'lazyvim.plugins.extras.editor.snacks_picker' },
    { import = 'lazyvim.plugins.extras.editor.snacks_explorer' },
    { import = 'lazyvim.plugins.extras.coding.blink' },
    { import = 'lazyvim.plugins.extras.lang.ansible' },
    { import = 'lazyvim.plugins.extras.lang.yaml' },
    { import = 'lazyvim.plugins.extras.lang.json' },
    { import = 'lazyvim.plugins.extras.lang.python' },
    { import = 'lazyvim.plugins.extras.dap.core' },
    { import = 'lazyvim.plugins.extras.test.core' },
    { import = 'plugins' },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { 'tokyonight', 'habamax' } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = { 'gzip', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' },
    },
  },
})
