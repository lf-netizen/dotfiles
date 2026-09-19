return {
  {
    'lewis6991/gitsigns.nvim',
    cond = not vim.g.vscode,

    opts = {
      current_line_blame = false,
      signs = { delete = { text = '▶' }, topdelete = { text = '▶' } },
      signs_staged = { delete = { text = '▶' }, topdelete = { text = '▶' } },
      on_attach = function(buf)
        local gs = require('gitsigns')
        for key, direction in pairs({ ['[h'] = 'prev', [']h'] = 'next' }) do
          vim.keymap.set('n', key, function()
            gs.nav_hunk(direction)
          end, { buffer = buf, desc = direction .. ' hunk' })
        end
        vim.keymap.set('n', '<leader>gp', gs.preview_hunk, { buffer = buf, desc = 'Preview hunk' })
        vim.keymap.set('n', '<leader>gP', gs.blame_line, { buffer = buf, desc = 'Blame line' })
      end,
    },
  },

  {
    'esmuellert/codediff.nvim',
    cond = not vim.g.vscode,
    cmd = 'CodeDiff',

    opts = {
      keymaps = {
        view = { toggle_stage = false, stage_hunk = false, unstage_hunk = false, discard_hunk = false },
        explorer = { stage_all = false, unstage_all = false, restore = false },
      },
    },

    keys = {
      { '<leader>gr', '<cmd>CodeDiff<cr>', desc = 'Review worktree changes' },
      {
        '<leader>gR',
        function()
          require('config.review').branch()
        end,
        desc = 'Review branch',
      },
      {
        '<leader>gw',
        function()
          require('config.review').worktree()
        end,
        desc = 'Review another worktree',
      },
    },
  },

  {
    'pwntester/octo.nvim',
    cond = not vim.g.vscode,
    cmd = 'Octo',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' },

    opts = {
      picker = 'snacks',
      enable_builtin = true,
      mappings_disable_default = true,
      mappings = {
        pull_request = {
          review_start = { lhs = '<leader>or', desc = 'Start review' },
          review_resume = { lhs = '<leader>oR', desc = 'Resume review' },
          add_comment = { lhs = '<leader>oc', desc = 'Add comment' },
        },
        review_diff = {
          add_review_comment = { lhs = '<leader>oc', desc = 'Review comment', mode = { 'n', 'x' } },
          select_next_entry = { lhs = ']q', desc = 'Next file' },
          select_prev_entry = { lhs = '[q', desc = 'Previous file' },
          next_thread = { lhs = ']t', desc = 'Next thread' },
          prev_thread = { lhs = '[t', desc = 'Previous thread' },
          focus_files = { lhs = '<leader>oe', desc = 'Review files' },
          close_review_tab = { lhs = 'q', desc = 'Close review' },
        },
        review_thread = { add_comment = { lhs = '<leader>oc', desc = 'Add comment' } },
        file_panel = {
          next_entry = { lhs = 'j', desc = 'Next file' },
          prev_entry = { lhs = 'k', desc = 'Previous file' },
          select_entry = { lhs = '<CR>', desc = 'Open file diff' },
          close_review_tab = { lhs = 'q', desc = 'Close review' },
        },
        submit_win = {
          approve_review = { lhs = '<C-a>', desc = 'Approve review', mode = { 'n' } },
          comment_review = { lhs = '<C-m>', desc = 'Comment review', mode = { 'n' } },
          request_changes = { lhs = '<C-r>', desc = 'Request changes', mode = { 'n' } },
          close_review_tab = { lhs = '<C-c>', desc = 'Close', mode = { 'n' } },
        },
      },
    },

    keys = {
      { '<leader>op', '<cmd>Octo pr list<cr>', desc = 'GitHub pull requests' },
      {
        '<leader>oo',
        function()
          vim.ui.input({ prompt = 'PR number or URL: ' }, function(value)
            if not value or value == '' then
              return
            end
            if value:match('^%d+$') then
              vim.cmd({ cmd = 'Octo', args = { 'pr', 'edit', value } })
            elseif value:match('^https://') then
              vim.cmd({ cmd = 'Octo', args = { value } })
            else
              vim.notify('Enter a PR number or HTTPS URL', vim.log.levels.WARN)
            end
          end)
        end,
        desc = 'Open GitHub PR',
      },
    },
  },
}
