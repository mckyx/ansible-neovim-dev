return {
  {
    'mason-org/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- The Python extra handles basedpyright/ruff LSP. Debugpy is for DAP.
      vim.list_extend(opts.ensure_installed, { 'debugpy', 'ruff' })
    end,
  },
  {
    'stevearc/conform.nvim',
    opts = {
      -- Ruff does both formatting and linting; avoids Black/isort conflicts.
      formatters_by_ft = { python = { 'ruff_format' } },
    },
  },
}
