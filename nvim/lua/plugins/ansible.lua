local venv = vim.fn.expand('~/.venvs/ansible-dev/bin')

return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        ansiblels = {
          root_markers = { 'ansible.cfg', '.ansible-lint', '.git' },
          settings = {
            ansible = {
              ansible = {
                path = venv .. '/ansible',
                useFullyQualifiedCollectionNames = true,
              },
              validation = {
                enabled = true,
                lint = {
                  enabled = true,
                  path = venv .. '/ansible-lint',
                  autoFixOnSave = false,
                },
              },
              python = {
                interpreterPath = venv .. '/python',
              },
            },
          },
        },
      },
    },
  },
  {
    'mfussenegger/nvim-ansible',
    -- Neotest's <leader>ta means attach; use <leader>ar for Ansible run.
    ft = { 'yaml', 'yaml.ansible' },
    keys = { { '<leader>ta', false } },
  },
}
