return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim', 'nvim-tree/nvim-web-devicons' },
  lazy = false, -- neo-tree will lazily load itself
  opts = function(_, opts)
    local function on_move(data)
      Snacks.rename.on_rename_file(data.source, data.destination)
    end
    local events = require 'neo-tree.events'
    opts.event_handlers = opts.event_handlers or {}
    vim.list_extend(opts.event_handlers, {
      { event = events.FILE_MOVED, handler = on_move },
      { event = events.FILE_RENAMED, handler = on_move },
    })

    ---@module 'neo-tree'
    ---@type neotree.Config
    opts = vim.tbl_deep_extend('force', opts, {
      filesystem = { follow_current_file = { enabled = true } },
    })
    return opts
  end,
  keys = {
    { '<leader>E', mode = 'n', '<cmd>Neotree toggle<cr>' },
    {
      '<leader>e',
      mode = 'n',
      function()
        local manager = require 'neo-tree.sources.manager'
        local state = manager.get_state 'filesystem'
        local winid = state and state.winid

        if winid and vim.api.nvim_win_is_valid(winid) then
          if vim.api.nvim_get_current_win() == winid then
            -- if we're already in Neo-tree, go back
            vim.cmd 'wincmd p'
          else
            -- Neo-tree is open but not focused → focus it
            vim.cmd 'Neotree focus'
          end
        else
          -- Neo-tree isn't open → toggle it open
          vim.cmd 'Neotree toggle'
        end
      end,
      { desc = 'Smart toggle Neo-tree / previous buffer' },
    },
  },
}
