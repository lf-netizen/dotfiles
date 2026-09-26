return {
  { 'folke/lazydev.nvim', cond = not vim.g.vscode, ft = 'lua', opts = {} },
  {
    'neovim/nvim-lspconfig',
    cond = not vim.g.vscode,
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      { 'mason-org/mason-lspconfig.nvim', opts = { automatic_enable = false } },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'saghen/blink.cmp',
    },

    config = function()
      require('config.diagnostics').setup()
      require('mason-tool-installer').setup({
        ensure_installed = { 'ty', 'ruff', 'lua-language-server', 'vtsls', 'biome', 'stylua', 'marksman' },
      })
      local project = require('config.project')
      local servers = {
        ty = {},
        ruff = {
          on_attach = function(client)
            client.server_capabilities.hoverProvider = false
          end,
        },
        lua_ls = {
          settings = {
            Lua = { workspace = { checkThirdParty = false }, completion = { callSnippet = 'Replace' } },
          },
        },
        vtsls = {},
        biome = {},
        marksman = {},
      }
      vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

      for name, opts in pairs(servers) do
        local command = vim.deepcopy(vim.lsp.config[name].cmd)
        if type(command) == 'table' then
          opts.cmd = function(dispatchers, config)
            local cmd = vim.deepcopy(command)
            local root = config.root_dir or project.root()
            for _, path in ipairs({
              root .. '/.venv/bin/' .. cmd[1],
              root .. '/node_modules/.bin/' .. cmd[1],
            }) do
              if vim.fn.executable(path) == 1 then
                cmd[1] = path
                break
              end
            end
            return vim.lsp.rpc.start(cmd, dispatchers, { cwd = root, env = config.cmd_env })
          end
        end
        vim.lsp.config(name, opts)
        vim.lsp.enable(name)
      end
    end,
  },
}
