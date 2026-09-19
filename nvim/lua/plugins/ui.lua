return {
  {
    'rebelot/kanagawa.nvim',
    cond = not vim.g.vscode,
    priority = 1000,

    opts = {
      transparent = true,
      theme = 'wave',
      keywordStyle = { italic = false },
      colors = { theme = { all = { ui = { bg_gutter = 'none' } } } },
      overrides = function(colors)
        return {
          NormalFloat = { bg = 'none' },
          FloatBorder = { bg = 'none' },
          FloatTitle = { bg = 'none' },
          Pmenu = { fg = colors.theme.ui.shade0, bg = 'none' },
          PmenuSel = { bg = colors.theme.ui.bg_p2 },
          BlinkCmpMenuBorder = { link = 'FloatBorder' },
          DiffChange = { bg = 'none' },
          LineNr = { fg = '#7C7C99' },
          StatusLine = { fg = '#7C7C99', bg = 'none', bold = false, italic = false },
          StatusLineBranch = { fg = colors.palette.oniViolet, bg = 'none', bold = false, italic = false },
          StatusLineNC = { fg = '#7C7C99', bg = 'none', bold = false, italic = false },
          FlashBackdrop = { italic = true },
          FlashLabel = { fg = '#000000', bg = '#FFDE63', bold = true },
          SnacksIndent = { fg = '#66667E', bg = 'none', italic = false, bold = false, nocombine = true },
          SnacksIndentBlank = { link = 'SnacksIndent' },
          SnacksIndentScope = { fg = '#9A9AB4', bg = 'none', italic = false, bold = false, nocombine = true },
        }
      end,
    },

    config = function(_, opts)
      require('kanagawa').setup(opts)
      vim.cmd.colorscheme('kanagawa')
    end,
  },

  {
    'folke/which-key.nvim',
    cond = not vim.g.vscode,
    event = 'VeryLazy',

    opts = {
      spec = {
        { '<leader>b', group = 'buffers' },
        { '<leader>c', group = 'code' },
        { '<leader>d', group = 'debug' },
        { '<leader>f', group = 'files' },
        { '<leader>g', group = 'git' },
        { '<leader>o', group = 'GitHub' },
        { '<leader>q', group = 'quit' },
        { '<leader>s', group = 'search' },
        { '<leader>t', group = 'test' },
        { '<leader>u', group = 'UI' },
        { '<leader>x', group = 'lists' },
      },
    },

    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({ global = false })
        end,
        desc = 'Buffer keymaps',
      },
    },
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    cond = not vim.g.vscode,
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },

    opts = {},

    keys = {
      {
        '<leader>um',
        function()
          require('render-markdown').toggle()
        end,
        desc = 'Markdown rendering',
      },
    },
  },
}
