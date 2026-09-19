return {
  {
    'folke/trouble.nvim',
    cond = not vim.g.vscode,
    cmd = 'Trouble',

    opts = { focus = true, follow = false },

    keys = {
      { '<leader>cS', '<cmd>Trouble symbols toggle focus=false win.position=right<cr>', desc = 'Outline' },
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer diagnostics' },
      { '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP results' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Trouble quickfix' },
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Trouble location list' },
    },
  },

  {
    'folke/todo-comments.nvim',
    cond = not vim.g.vscode,
    dependencies = { 'nvim-lua/plenary.nvim' },

    opts = { signs = false },

    keys = {
      {
        '[t',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Previous TODO',
      },
      {
        ']t',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next TODO',
      },
      {
        '<leader>st',
        function()
          Snacks.picker.todo_comments()
        end,
        desc = 'TODOs',
      },
      {
        '<leader>sT',
        function()
          Snacks.picker.todo_comments({ keywords = { 'TODO', 'FIX', 'FIXME' } })
        end,
        desc = 'TODO / FIXME',
      },
      { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'TODO list' },
      {
        '<leader>xT',
        '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>',
        desc = 'TODO / FIXME list',
      },
    },
  },

  {
    'MagicDuck/grug-far.nvim',
    cond = not vim.g.vscode,
    cmd = 'GrugFar',

    opts = { headerMaxWidth = 80 },

    keys = {
      {
        '<leader>sr',
        function()
          local ext = vim.bo.buftype == '' and vim.fn.expand('%:e') or ''
          require('grug-far').open({
            transient = true,
            prefills = { filesFilter = ext ~= '' and '*.' .. ext or nil },
          })
        end,
        mode = { 'n', 'x' },
        desc = 'Search / replace',
      },
    },
  },
}
