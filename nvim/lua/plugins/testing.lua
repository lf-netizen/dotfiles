return {
  'nvim-neotest/neotest',
  cond = not vim.g.vscode,
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-python',
  },

  opts = function()
    return {
      adapters = {
        require('neotest-python')({
          runner = 'pytest',
          python = function()
            return require('config.project').python()
          end,
        }),
      },
      status = { virtual_text = false, signs = true },
      output = { open_on_run = false },
      quickfix = {
        open = function()
          require('trouble').open({ mode = 'quickfix', focus = false, follow = false })
        end,
      },
    }
  end,

  keys = {
    {
      '<leader>tn',
      function()
        require('neotest').run.run()
      end,
      desc = 'Test nearest',
    },

    {
      '<leader>ta',
      function()
        require('neotest').run.run(vim.fn.expand('%:p'))
      end,
      desc = 'Test file',
    },

    {
      '<leader>tA',
      function()
        require('neotest').run.run(require('config.project').root())
      end,
      desc = 'Test project',
    },

    {
      '<leader>tl',
      function()
        require('neotest').run.run_last()
      end,
      desc = 'Test last',
    },

    {
      '<leader>ts',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Test summary',
    },

    {
      '<leader>to',
      function()
        require('neotest').output.open({ enter = true, auto_close = true })
      end,
      desc = 'Test output',
    },

    {
      '<leader>tO',
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = 'Test output panel',
    },

    {
      '<leader>tS',
      function()
        require('neotest').run.stop()
      end,
      desc = 'Stop tests',
    },

    {
      '<leader>tw',
      function()
        require('neotest').watch.toggle(vim.fn.expand('%:p'))
      end,
      desc = 'Watch tests',
    },

    {
      '<leader>td',
      function()
        require('lazy').load({ plugins = { 'nvim-dap' } })
        require('neotest').run.run({ strategy = 'dap' })
      end,
      desc = 'Debug nearest test',
    },
  },
}
