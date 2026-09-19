return {
  'mfussenegger/nvim-dap',
  cond = not vim.g.vscode,
  dependencies = {
    { 'igorlfs/nvim-dap-view', opts = { windows = { terminal = { hide = { 'python' } } } } },
    { 'theHamsta/nvim-dap-virtual-text', opts = {} },
    'mfussenegger/nvim-dap-python',
    'nvim-lua/plenary.nvim',
  },

  keys = {
    {
      '<leader>da',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Breakpoint',
    },

    {
      '<leader>dA',
      function()
        vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(value)
          if value then
            require('dap').set_breakpoint(value)
          end
        end)
      end,
      desc = 'Conditional breakpoint',
    },

    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Start / continue',
    },

    {
      '<leader>dC',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Run to cursor',
    },

    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Step into',
    },

    {
      '<leader>do',
      function()
        require('dap').step_over()
      end,
      desc = 'Step over',
    },

    {
      '<leader>dO',
      function()
        require('dap').step_out()
      end,
      desc = 'Step out',
    },

    {
      '<leader>dP',
      function()
        require('dap').pause()
      end,
      desc = 'Pause',
    },

    {
      '<leader>dr',
      function()
        require('dap').run_last()
      end,
      desc = 'Run last',
    },

    {
      '<leader>dQ',
      function()
        require('dap').terminate()
      end,
      desc = 'Terminate',
    },

    {
      '<leader>dK',
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = 'Inspect value',
    },

    {
      '<leader>dd',
      function()
        require('dap-view').toggle()
      end,
      desc = 'Debug view',
    },
  },

  config = function()
    local dap, view = require('dap'), require('dap-view')
    require('dap-python').setup('uv')
    require('dap-python').resolve_python = function()
      return require('config.project').python()
    end
    require('dap.ext.vscode').json_decode = function(text)
      return vim.json.decode(require('plenary.json').json_strip_comments(text))
    end
    dap.listeners.after.event_initialized['view'] = function()
      view.open()
    end
    dap.listeners.before.event_terminated['view'] = function()
      view.close()
    end
    dap.listeners.before.event_exited['view'] = function()
      view.close()
    end
    for name, icon in pairs({
      Breakpoint = '●',
      BreakpointCondition = '◆',
      BreakpointRejected = '○',
      Stopped = '▶',
      LogPoint = '◈',
    }) do
      vim.fn.sign_define(
        'Dap' .. name,
        { text = icon, texthl = name == 'Stopped' and 'DiagnosticWarn' or 'DiagnosticError' }
      )
    end
  end,
}
