return {
  'rebelot/kanagawa.nvim',
  priority = 1000,
  opts = {
    keywordStyle = { italic = false },
    colors = {
      theme = {
        all = {
          ui = {
            bg_gutter = 'none',
          },
        },
      },
    },
    transparent = true,
    theme = 'wave',
    overrides = function(colors)
      local theme = colors.theme
      return {
        NormalFloat = { bg = 'none' },
        FloatBorder = { bg = 'none' },
        FloatTitle = { bg = 'none' },

        Pmenu = { fg = theme.ui.shade0, bg = 'none' },
        PmenuSel = { fg = 'none', bg = theme.ui.bg_p2 },
        PmenuSbar = { bg = theme.ui.bg_m1 },
        PmenuThumb = { bg = theme.ui.bg_p2 },

        BlinkCmpMenuBorder = { link = 'FloatBorder' },

        DiffChange = { bg = 'none' },

        LineNr = { fg = '#7C7C99' },
        StatusLine = { bg = 'none' },
        StatusLineNC = { bg = 'none' },
      }
    end,
  },
  init = function()
    vim.cmd 'colorscheme kanagawa'
  end,
}
