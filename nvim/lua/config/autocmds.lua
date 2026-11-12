-- Ansible is YAML, but the Ansible LSP needs the more specific yaml.ansible type.
-- Do not label ALL YAML as Ansible (CI workflows, Compose, etc. are not playbooks).
vim.filetype.add({
  filename = {
    ['site.yml'] = 'yaml.ansible',
    ['site.yaml'] = 'yaml.ansible',
    ['playbook.yml'] = 'yaml.ansible',
    ['playbook.yaml'] = 'yaml.ansible',
  },
  pattern = {
    ['.*/playbooks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/tasks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/handlers/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/defaults/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/group_vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/host_vars/.*%.ya?ml'] = 'yaml.ansible',
  },
})
vim.treesitter.language.register('yaml', 'yaml.ansible')

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'yaml.ansible', 'yaml' },
  callback = function(event)
    vim.bo[event.buf].expandtab = true
    vim.bo[event.buf].shiftwidth = 2
    vim.bo[event.buf].tabstop = 2
    vim.bo[event.buf].softtabstop = 2
    if vim.bo[event.buf].filetype == 'yaml.ansible' then
      -- Autoformatting can change Jinja expressions; trigger explicitly if needed.
      vim.b[event.buf].autoformat = false
      vim.keymap.set('n', '<leader>ar', function()
        require('ansible').run()
      end, { buffer = event.buf, desc = 'Ansible: run playbook/role' })
    end
  end,
})
