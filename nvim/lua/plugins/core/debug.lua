-- return {
--   { 'rcarriga/nvim-dap-ui', enabled = false },
--   {
--     'miroshQa/debugmaster.nvim',
--     -- osv is needed if you want to debug neovim lua code. Also can be used
--     -- as a way to quickly test-drive the plugin without configuring debug adapters
--     dependencies = { 'mfussenegger/nvim-dap', 'jbyuki/one-small-step-for-vimkind', 'mfussenegger/nvim-dap-python' },
--     config = function()
--       local dm = require 'debugmaster'
--       -- make sure you don't have any other keymaps that starts with "<leader>d" to avoid delay
--       -- Alternative keybindings to "<leader>d" could be: "<leader>m", "<leader>;"
--       vim.keymap.set({ 'n', 'v' }, '<leader>d', dm.mode.toggle, { nowait = true })
--       -- If you want to disable debug mode in addition to leader+d using the Escape key:
--       -- vim.keymap.set("n", "<Esc>", dm.mode.disable)
--       -- This might be unwanted if you already use Esc for ":noh"
--       vim.keymap.set('t', '<C-\\>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
--
--       dm.plugins.osv_integration.enabled = true -- needed if you want to debug neovim lua code
--       local dap = require 'dap'
--       -- Configure your debug adapters here
--       -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
--       require('dap-python').setup 'uv'
--     end,
--
--     init = function()
--       -- Define DAP signs with Nerd Font icons
--       vim.fn.sign_define('DapBreakpoint', {
--         text = '', -- Circle with a border (Nerd Font icon, good for breakpoints)
--         texthl = 'DapBreakpoint',
--         linehl = '',
--         numhl = '',
--       })
--
--       vim.fn.sign_define('DapBreakpointCondition', {
--         text = '', -- Filled circle with a border (good for conditional breakpoints)
--         texthl = 'DapBreakpointCondition',
--         linehl = '',
--         numhl = '',
--       })
--
--       vim.fn.sign_define('DapLogPoint', {
--         text = '', -- Chat bubble icon (Nerd Font, good for log points)
--         texthl = 'DapLogPoint',
--         linehl = '',
--         numhl = '',
--       })
--
--       vim.fn.sign_define('DapStopped', {
--         text = '', -- Right arrow with a line (indicates current execution point)
--         texthl = 'DapStopped',
--         linehl = 'DapStoppedLine', -- Highlight the entire line (optional)
--         numhl = 'DapStopped',
--       })
--
--       vim.fn.sign_define('DapBreakpointRejected', {
--         text = '', -- Crossed-out circle (good for rejected breakpoints)
--         texthl = 'DapBreakpointRejected',
--         linehl = '',
--         numhl = '',
--       })
--
--       -- Optionally define highlight groups if your colorscheme doesn’t already include these
--       vim.cmd [[
--           highlight DapBreakpoint guifg=#FF5555
--           highlight DapBreakpointCondition guifg=#55AAFF
--           highlight DapLogPoint guifg=#55FF55
--           highlight DapStopped guifg=#FFFF55
--           highlight DapStoppedLine guibg=#444444
--           highlight DapBreakpointRejected guifg=#FF5555 gui=bold
--       ]]
--     end,
--   },
-- }
--
--
--
--
--

return {
  -- { 'nvimtools/hydra.nvim' },
  {
    -- NOTE: Yes, you can install new plugins here!
    'mfussenegger/nvim-dap',
    -- NOTE: And you can specify dependencies as well
    dependencies = {
      -- Creates a beautiful debugger UI
      {
        'igorlfs/nvim-dap-view',
        opts = {
          windows = {
            terminal = {
              width = 0.2,
              hide = { 'python' },
            },
          },
        },
      },
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
      },

      -- Keymaps
      'nvimtools/hydra.nvim',

      -- Installs the debug adapters for you
      'mason-org/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Add your own debuggers here
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require 'dap'
      local dapview = require 'dap-view'

      require('mason-nvim-dap').setup {
        automatic_installation = true,
        handlers = {},
        ensure_installed = {
          'debugpy',
        },
      }

      -- Change breakpoint icons
      vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
      local breakpoint_icons = vim.g.have_nerd_font
          and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
        or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
      for type, icon in pairs(breakpoint_icons) do
        local tp = 'Dap' .. type
        local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
        vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      end

      dap.listeners.after.event_initialized['dapui_config'] = dapview.open
      dap.listeners.before.event_terminated['dapui_config'] = dapview.close
      dap.listeners.before.event_exited['dapui_config'] = dapview.close

      -- setup dap config by VsCode launch.json file
      local vscode = require 'dap.ext.vscode'
      local json = require 'plenary.json'
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end

      require('dap-python').setup 'uv'

      local Hydra = require 'hydra'
      local dap_hydra = Hydra {
        name = 'Debugging (DAP)',
        config = {
          color = 'pink',
          invoke_on_body = true,
          -- buffer = true,
        },
        mode = { 'n', 'v' },
        body = '<leader>d',
        -- stylua: ignore
        heads = {
            { 'a', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' } },
            { 'A', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Toggle Conditional Breakpoint' }, },
            { 'c', dap.continue, { desc = 'Continue' } },
            { 'C', dap.run_to_cursor, { desc = 'Run to Cursor' } },
            { 'i', dap.step_into, { desc = 'Step Into' } },
            { 'o', dap.step_over, { desc = 'Step Over' } },
            { 'O', dap.step_out, { desc = 'Step Out' } },
            -- { 'g', dap.goto_, { desc = 'GoTo' } },
            -- { "j", dap.down },
            -- { "k", dap.up },
            { 'P', dap.pause, { desc = 'Pause' } },
            -- { 'r', dap.repl.toggle },
            { 'r', dap.run_last, { desc = 'Run Last' } },
            { 'Q', dap.terminate, { desc = 'Terminate' } },
            { 'K', function() require('dap.ui.widgets').hover() end, desc = 'Widgets' },
            { 'q', nil, { exit = true } },
            { '<leader>d', nil, { exit = true } },

            { 'd', dapview.toggle, { desc = 'Toggle Debug View' } },


            {'<CR>', function ()
                local mode = vim.fn.mode()
                local lines
                
                if mode == 'v' or mode == 'V' or mode == '\22' then -- \22 is <C-v> (visual block)
                    -- Visual mode: get the visual selection
                    -- Exit visual mode first to make the marks work correctly
                    local start_pos = vim.fn.getpos('v')
                    local end_pos = vim.fn.getpos('.')
                    
                    -- Ensure start is before end
                    if start_pos[2] > end_pos[2] or (start_pos[2] == end_pos[2] and start_pos[3] > end_pos[3]) then
                        start_pos, end_pos = end_pos, start_pos
                    end
                    
                    lines = vim.fn.getregion(start_pos, end_pos, { type = mode })
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
                else
                    -- Normal mode: get the current line
                    lines = { vim.fn.getline('.') }
                end
                
                dap.repl.execute(table.concat(lines, "\n"))
            end}
        },
      }

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'dap-view', 'dap-view-term', 'dap-repl' }, -- dap-repl is set by `nvim-dap`
        callback = function(args)
          vim.keymap.set('n', 'q', '<C-w>q', { buffer = args.buf })
        end,
      })

      -- local dap_enabled_filetypes = {
      --   go = true,
      --   python = true,
      --   rust = true,
      --   typescript = true,
      --   javascript = true,
      --   lua = true, -- for debugging Neovim plugins!
      -- }
      --
      -- vim.api.nvim_create_autocmd('FileType', {
      --   pattern = '*', -- Run for every filetype to check against our list
      --   group = vim.api.nvim_create_augroup('BufferLocalHydras', { clear = true }),
      --   callback = function(args)
      --     -- `args.buf` is the buffer number of the file that was just opened.
      --     -- `args.match` is the filetype.
      --
      --     -- Check if the current filetype is in our list of allowed types.
      --     if dap_enabled_filetypes[args.match] then
      --       -- If it is, create a keymap ONLY for this buffer.
      --       -- The function we map to is `dap_hydra.body`. This special function
      --       -- is created by hydra.nvim to trigger the hydra.
      --       vim.keymap.set('n', '<leader>d', dap_hydra.body, {
      --         buffer = args.buf, -- This is the key! It makes the map buffer-local.
      --         desc = 'Hydra: Debugger (DAP)',
      --       })
      --       -- If you also want it in visual mode
      --       vim.keymap.set('v', '<leader>d', dap_hydra.body, {
      --         buffer = args.buf,
      --         desc = 'Hydra: Debugger (DAP)',
      --       })
      --     end
      --   end,
      -- })
    end,
  },
}
