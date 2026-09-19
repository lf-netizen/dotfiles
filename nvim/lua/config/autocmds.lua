local group = vim.api.nvim_create_augroup('Editor', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = group,
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

if vim.g.vscode then
  return
end

vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, { group = group, command = 'checktime' })
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = { 'help', 'qf', 'checkhealth', 'grug-far' },
  callback = function(event)
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, desc = 'Close view' })
  end,
})
