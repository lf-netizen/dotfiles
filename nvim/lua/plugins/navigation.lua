return {
  {
    'smart-splits-nvim/smart-splits.nvim',
    cond = not vim.g.vscode,
    lazy = false,

    opts = { at_edge = 'stop', multiplexer_integration = vim.env.HERDR_ENV and 'herdr' or false },

    config = function(_, opts)
      local splits = require('smart-splits')
      splits.setup(opts)

      if opts.multiplexer_integration == 'herdr' then
        local mux = require('smart-splits.mux.herdr')
        local resize = mux.resize_pane
        -- Herdr's resize API uses fractions; editor steps are whole cells.
        mux.resize_pane = function(direction, amount)
          return resize(direction, amount / 100)
        end
      end

      for key, direction in pairs({ h = 'left', j = 'down', k = 'up', l = 'right' }) do
        vim.keymap.set('n', '<C-' .. key .. '>', splits['move_cursor_' .. direction], { desc = 'Focus ' .. direction })
      end

      for key, direction in pairs({ h = 'left', j = 'down', k = 'up', l = 'right' }) do
        vim.keymap.set('n', '<C-S-A-' .. key .. '>', splits['resize_' .. direction], { desc = 'Resize ' .. direction })
      end

      for key, direction in pairs({ Left = 'left', Down = 'down', Up = 'up', Right = 'right' }) do
        vim.keymap.set(
          'n',
          '<C-S-' .. key .. '>',
          splits['move_cursor_' .. direction],
          { desc = 'Focus ' .. direction }
        )
        vim.keymap.set('n', '<C-' .. key .. '>', splits['move_cursor_' .. direction], { desc = 'Focus ' .. direction })
        vim.keymap.set('n', '<C-S-A-' .. key .. '>', splits['resize_' .. direction], { desc = 'Resize ' .. direction })
      end
    end,
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    cond = not vim.g.vscode,
    lazy = false,
    branch = 'v3.x',
    dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim', 'nvim-tree/nvim-web-devicons' },

    opts = function()
      local events = require('neo-tree.events')

      local function rename(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end
      return {
        filesystem = { follow_current_file = { enabled = true } },
        event_handlers = {
          { event = events.FILE_MOVED, handler = rename },
          { event = events.FILE_RENAMED, handler = rename },
        },
      }
    end,

    keys = {
      { '<leader>E', '<cmd>Neotree toggle<cr>', desc = 'Toggle explorer' },
      {
        '<leader>e',
        function()
          local state = require('neo-tree.sources.manager').get_state('filesystem')
          if state.winid and vim.api.nvim_win_is_valid(state.winid) then
            if vim.api.nvim_get_current_win() == state.winid then
              vim.cmd('wincmd p')
            else
              vim.cmd('Neotree focus')
            end
          else
            vim.cmd('Neotree toggle')
          end
        end,
        desc = 'Explorer / previous window',
      },
    },
  },
}
