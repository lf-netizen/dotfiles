return {
  'stevearc/conform.nvim',
  cond = not vim.g.vscode,
  event = 'BufWritePre',
  cmd = 'ConformInfo',

  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format({ async = true, lsp_format = 'fallback' })
      end,
      mode = { 'n', 'x' },
      desc = 'Format',
    },

    {
      '<leader>cs',
      function()
        vim.b.skip_format = true
        local ok, err = pcall(vim.cmd.write)
        vim.b.skip_format = nil
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end,
      desc = 'Save without formatting',
    },
  },

  opts = {
    notify_on_error = true,
    format_on_save = function(buf)
      if vim.b[buf].skip_format or vim.bo[buf].buftype ~= '' then
        return
      end

      if vim.tbl_contains({ 'c', 'cpp' }, vim.bo[buf].filetype) then
        return
      end
      return { timeout_ms = 1000, lsp_format = 'fallback' }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_organize_imports', 'ruff_format' },
      javascript = { 'biome-organize-imports', 'biome' },
      javascriptreact = { 'biome-organize-imports', 'biome' },
      typescript = { 'biome-organize-imports', 'biome' },
      typescriptreact = { 'biome-organize-imports', 'biome' },
    },
    formatters = {
      biome = { require_cwd = true },
      ['biome-organize-imports'] = { require_cwd = true },
      ruff_format = {
        command = function(_, ctx)
          return require('config.project').command('ruff', ctx.buf)
        end,
      },
      ruff_organize_imports = {
        command = function(_, ctx)
          return require('config.project').command('ruff', ctx.buf)
        end,
      },
    },
  },
}
