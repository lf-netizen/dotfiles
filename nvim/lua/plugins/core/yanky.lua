return {
  'gbprod/yanky.nvim',
  opts = {},
  dependencies = { 'folke/snacks.nvim' },
  keys = {
    {
      '<leader>Y',
      function()
        Snacks.picker.yanky()
      end,
      mode = { 'n', 'x' },
      desc = 'Open Yank History',
    },
  },
  init = function()
    vim.api.nvim_set_hl(0, 'YankHighlight', { link = 'Search' })
    vim.api.nvim_create_autocmd('TextYankPost', {
      callback = function()
        vim.highlight.on_yank {
          higroup = 'YankHighlight',
          timeout = 200,
        }
      end,
    })
  end,
}
