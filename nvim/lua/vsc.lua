require 'options'

-- keymaps
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
-- vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- vim.keymap.set('n', 'zz', '<cmd>call VSCodeNotify("workbench.action.closeActiveEditor")<cr>')

vim.keymap.set('i', '<C-c>', '<Esc>')

vim.keymap.set({ 'n', 'v' }, '<leader>p', [["+p]])
vim.keymap.set('v', '<leader>y', [["+y]])

vim.keymap.set({ 'n', 'v' }, '<leader>p', [["+p]])
vim.keymap.set('v', '<leader>y', [["+y]])

vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- vim.keymap.set('n', '<C-w>', '<cmd>call VSCodeNotify("workbench.action.closeActiveEditor")<cr>', { desc = 'Quit buffer' })
-- vim.keymap.del('n', '<C-w>d')
-- vim.keymap.del('n', '<C-w><C-d>')

vim.keymap.set('n', '<leader>-', '<cmd>call VSCodeNotify("workbench.action.splitEditorDown")<CR>', { desc = 'Split window below', remap = true })
vim.keymap.set('n', '<leader>\\', '<cmd>call VSCodeNotify("workbench.action.splitEditorRight")<CR>', { desc = 'Split window right', remap = true })

-- vim.keymap.set('n', '<S-h>', '<cmd>call VSCodeNotify("workbench.action.previousEditor")<CR>', { silent = true, desc = 'Prev buffer' })
-- vim.keymap.set('n', '<S-l>', '<cmd>call VSCodeNotify("workbench.action.nextEditor")<CR>', { silent = true, desc = 'Next buffer' })
-- vim.keymap.set('n', '<Tab>', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })

vim.keymap.set('n', 'gd', '<cmd>call VSCodeNotify("editor.action.revealDefinition")<CR>', { silent = true, desc = 'Go to definition' })
vim.keymap.set('n', 'gr', '<cmd>call VSCodeNotify("editor.action.goToReferences")<CR>', { silent = true, desc = 'Go to references' })

vim.keymap.set('n', '<leader>h', '<cmd>call VSCodeNotify("vscode-harpoon.editEditors")<CR>', { desc = 'Open Harpoon menu', remap = true })
vim.keymap.set('n', '<leader>H', '<cmd>call VSCodeNotify("vscode-harpoon.addEditor")<CR>', { desc = 'Add File to Harpoon', remap = true })
vim.keymap.set('n', '<leader>e', '<cmd>call VSCodeNotify("workbench.view.explorer")<CR>', { desc = 'Open File Explorer', remap = true })

vim.api.nvim_set_hl(0, 'YankHighlight', { bg = '#a9dc76', blend = 50 })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank {
      higroup = 'IncSearch',
      timeout = 250,
    }
  end,
})

require 'lazy-bootstrap'
require('lazy').setup {
  require 'plugins.core.treesitter',
  require 'plugins.core.flash',
  require 'plugins.core.surround',
}
