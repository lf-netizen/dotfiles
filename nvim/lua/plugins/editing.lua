return {
  {
    'folke/flash.nvim',

    opts = {},

    config = function(_, opts)
      require('flash').setup(opts)

      local function highlights()
        vim.api.nvim_set_hl(0, 'FlashBackdrop', { italic = true })
        vim.api.nvim_set_hl(0, 'FlashLabel', { fg = '#000000', bg = '#FFDE63', bold = true })
      end
      highlights()
      vim.api.nvim_create_autocmd(
        'ColorScheme',
        { group = vim.api.nvim_create_augroup('FlashColors', { clear = true }), callback = highlights }
      )
    end,

    keys = {
      {
        's',
        function()
          require('flash').jump()
        end,
        mode = { 'n', 'x', 'o' },
        desc = 'Flash',
      },
      {
        'S',
        function()
          require('flash').treesitter()
        end,
        mode = { 'n', 'x', 'o' },
        desc = 'Flash syntax',
      },
    },
  },

  { 'kylechui/nvim-surround', version = '^3.0.0', opts = { keymaps = { visual = 'gS', visual_line = 'gss' } } },
  { 'nvim-mini/mini.pairs', cond = not vim.g.vscode, opts = {} },
  {
    'nvim-mini/mini.comment',
    cond = not vim.g.vscode,

    opts = {},

    config = function(_, opts)
      require('mini.comment').setup(opts)
      vim.keymap.set('n', '<C-/>', 'gcc', { remap = true, desc = 'Comment line' })
      vim.keymap.set('x', '<C-/>', 'gc', { remap = true, desc = 'Comment selection' })
    end,
  },

  {
    'chrisgrieser/nvim-various-textobjs',
    lazy = false,
    -- aS selects Treesitter scope; subwords use our lowercase as/is pair.

    opts = { keymaps = { useDefaults = true, disabledDefaults = { 'aS', 'iS' } } },

    config = function(_, opts)
      require('various-textobjs').setup(opts)

      for key, scope in pairs({ as = 'outer', is = 'inner' }) do
        vim.keymap.set({ 'o', 'x' }, key, function()
          require('various-textobjs').subword(scope)
        end, { desc = scope .. ' subword' })
      end
    end,
  },

  {
    'gbprod/yanky.nvim',
    cond = not vim.g.vscode,

    opts = {},

    keys = {
      {
        '<leader>y',
        function()
          Snacks.picker.yanky()
        end,
        desc = 'Yank history',
      },
    },
  },
}
