return {
  'MagicDuck/grug-far.nvim',
  opts = { headerMaxWidth = 80 },
  cmd = 'GrugFar',
  keys = {
    {
      '<leader>sr',
      function()
        local grug = require 'grug-far'
        local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
        grug.open {
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
          },
        }
      end,
      mode = { 'n', 'v' },
      desc = 'Search and Replace',
    },
  },
  init = function()
    local group = vim.api.nvim_create_augroup('close_with_q', { clear = true })
    vim.api.nvim_create_autocmd('filetype', {
      group = group,
      pattern = {
        'grug-far',
      },
      callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set('n', 'q', '<cmd>close<cr>', {
          buffer = event.buf,
          silent = true,
          desc = 'quit buffer',
        })
      end,
    })
  end,
}
