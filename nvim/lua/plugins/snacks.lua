local function picker(name, opts)
  return function()
    Snacks.picker[name](opts)
  end
end

return {
  'folke/snacks.nvim',
  cond = not vim.g.vscode,
  priority = 1000,
  lazy = false,

  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    image = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          {
            key = 'f',
            desc = 'Find file',
            action = function()
              Snacks.picker.files()
            end,
          },
          {
            key = 'g',
            desc = 'Search text',
            action = function()
              Snacks.picker.grep()
            end,
          },
          { key = 'r', desc = 'Review changes', action = ':CodeDiff' },
          { key = 'p', desc = 'GitHub pull requests', action = ':Octo pr list' },
          { key = 'n', desc = 'New file', action = ':ene | startinsert' },
          { key = 'L', desc = 'Plugins', action = ':Lazy' },
          { key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'recent_files', limit = 5, padding = 1 },
        { section = 'startup' },
      },
    },
    indent = {
      enabled = true,
      indent = { char = '│', hl = 'SnacksIndent' },
      scope = { char = '│', hl = 'SnacksIndentScope' },
      animate = { enabled = false },
    },
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    scope = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    picker = {
      enabled = true,
      matcher = { cwd_bonus = true, frecency = true, history_bonus = true },
      win = {
        input = {
          keys = {
            ['<C-j>'] = { 'list_down', mode = { 'i', 'n' } },
            ['<C-k>'] = { 'list_up', mode = { 'i', 'n' } },
          },
        },
      },
    },
  },

  keys = {
    { '<C-p>', picker('files', { layout = { preset = 'vscode' } }), desc = 'Find files' },
    { '<leader><space>', picker('smart'), desc = 'Smart files' },
    { '<leader>,', picker('buffers'), desc = 'Buffers' },
    { '<leader>/', picker('grep'), desc = 'Grep' },
    { '<leader>:', picker('command_history'), desc = 'Command history' },
    { '<leader>n', picker('notifications'), desc = 'Notification history' },
    { '<leader>fb', picker('buffers'), desc = 'Buffers' },
    {
      '<leader>fc',
      function()
        Snacks.picker.files({ cwd = vim.fn.stdpath('config') })
      end,
      desc = 'Config files',
    },

    { '<leader>ff', picker('files'), desc = 'Files' },
    { '<leader>fg', picker('git_files'), desc = 'Git files' },
    { '<leader>fr', picker('recent'), desc = 'Recent files' },
    { '<leader>gb', picker('git_branches'), desc = 'Branches' },
    { '<leader>gl', picker('git_log'), desc = 'Git log' },
    { '<leader>gL', picker('git_log_line'), desc = 'Line history' },
    { '<leader>gs', picker('git_status'), desc = 'Git status' },
    { '<leader>gS', picker('git_stash'), desc = 'Stashes' },
    { '<leader>gd', picker('git_diff'), desc = 'Diff hunks' },
    { '<leader>gf', picker('git_log_file'), desc = 'File history' },
    { '<leader>sb', picker('lines'), desc = 'Buffer lines' },
    { '<leader>sB', picker('grep_buffers'), desc = 'Grep buffers' },
    { '<leader>sg', picker('grep'), desc = 'Grep' },
    { '<leader>sw', picker('grep_word'), mode = { 'n', 'x' }, desc = 'Grep word / selection' },
    { '<leader>s"', picker('registers'), desc = 'Registers' },
    { '<leader>s/', picker('search_history'), desc = 'Search history' },
    { '<leader>sa', picker('autocmds'), desc = 'Autocommands' },
    { '<leader>sc', picker('command_history'), desc = 'Command history' },
    { '<leader>sC', picker('commands'), desc = 'Commands' },
    { '<leader>sd', picker('diagnostics'), desc = 'Diagnostics' },
    { '<leader>sD', picker('diagnostics_buffer'), desc = 'Buffer diagnostics' },
    { '<leader>sh', picker('help'), desc = 'Help' },
    { '<leader>sH', picker('highlights'), desc = 'Highlights' },
    { '<leader>sj', picker('jumps'), desc = 'Jumps' },
    { '<leader>sk', picker('keymaps'), desc = 'Keymaps' },
    { '<leader>sl', picker('loclist'), desc = 'Location list' },
    { '<leader>sm', picker('marks'), desc = 'Marks' },
    { '<leader>sM', picker('man'), desc = 'Manual pages' },
    { '<leader>sq', picker('qflist'), desc = 'Quickfix' },
    { '<leader>sR', picker('resume'), desc = 'Resume picker' },
    { '<leader>su', picker('undo'), desc = 'Undo history' },
    { 'gd', picker('lsp_definitions'), desc = 'Definition' },
    { 'gD', picker('lsp_declarations'), desc = 'Declaration' },
    { 'gr', picker('lsp_references'), nowait = true, desc = 'References' },
    { 'gI', picker('lsp_implementations'), desc = 'Implementation' },
    { 'gy', picker('lsp_type_definitions'), desc = 'Type definition' },
    { '<leader>ss', picker('lsp_symbols'), desc = 'Symbols' },
    { '<leader>sS', picker('lsp_workspace_symbols'), desc = 'Workspace symbols' },
    {
      '<leader>cR',
      function()
        Snacks.rename.rename_file()
      end,
      desc = 'Rename file',
    },

    {
      '<leader>gB',
      function()
        Snacks.gitbrowse()
      end,
      mode = { 'n', 'x' },
      desc = 'Browse on remote',
    },

    {
      '<leader>gg',
      function()
        Snacks.lazygit()
      end,
      desc = 'LazyGit',
    },

    {
      '<leader>un',
      function()
        Snacks.notifier.hide()
      end,
      desc = 'Dismiss notifications',
    },

    {
      '<leader>bd',
      function()
        Snacks.bufdelete()
      end,
      desc = 'Delete buffer',
    },

    {
      ']]',
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = 'Next reference',
    },

    {
      '[[',
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = 'Previous reference',
    },
  },

  config = function(_, opts)
    require('snacks').setup(opts)
    Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
    Snacks.toggle.option('spell', { name = 'Spell' }):map('<leader>us')
    Snacks.toggle.diagnostics():map('<leader>ud')
    Snacks.toggle.inlay_hints():map('<leader>uh')
    Snacks.toggle.indent():map('<leader>ug')
    Snacks.toggle.line_number():map('<leader>ul')
  end,
}
