return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',

    config = function()
      require('nvim-treesitter').install({
        'lua',
        'luadoc',
        'vim',
        'vimdoc',
        'query',
        'python',
        'javascript',
        'typescript',
        'tsx',
        'json',
        'yaml',
        'toml',
        'bash',
        'markdown',
        'markdown_inline',
        'diff',
        'html',
        'css',
      })
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('EditorTreesitter', { clear = true }),
        callback = function(event)
          if vim.bo[event.buf].buftype == '' then
            pcall(vim.treesitter.start, event.buf)
          end
        end,
      })
      vim.keymap.set({ 'n', 'x' }, '<C-Space>', function()
        vim.treesitter.select('parent')
      end, { desc = 'Expand syntax selection' })
      vim.keymap.set('x', '<BS>', function()
        vim.treesitter.select('child')
      end, { desc = 'Shrink syntax selection' })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },

    opts = {
      select = {
        lookahead = true,
        include_surrounding_whitespace = true,
        selection_modes = { ['@function.outer'] = 'V', ['@class.outer'] = '<C-v>' },
      },
    },

    config = function(_, opts)
      require('nvim-treesitter-textobjects').setup(opts)

      for key, capture in pairs({
        af = '@function.outer',
        ['if'] = '@function.inner',
        ac = '@class.outer',
        ic = '@class.inner',
      }) do
        vim.keymap.set({ 'x', 'o' }, key, function()
          require('nvim-treesitter-textobjects.select').select_textobject(capture, 'textobjects')
        end, { desc = capture })
      end
      vim.keymap.set({ 'x', 'o' }, 'aS', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@local.scope', 'locals')
      end, { desc = 'Scope' })
    end,
  },
}
