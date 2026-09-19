local function action(name)
  return function()
    require('vscode').action(name)
  end
end

local map = vim.keymap.set
map('n', 'gd', action('editor.action.revealDefinition'), { desc = 'Definition' })
map('n', 'gr', action('editor.action.goToReferences'), { desc = 'References' })
map('n', '<leader>e', action('workbench.view.explorer'), { desc = 'Explorer' })
map('n', '<leader>-', action('workbench.action.splitEditorDown'), { desc = 'Split below' })
map('n', '<leader>\\', action('workbench.action.splitEditorRight'), { desc = 'Split right' })
