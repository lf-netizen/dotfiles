local map = vim.keymap.set

map('n', 'J', 'mzJ`z')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '<C-z>', 'zz')
map('i', '<C-c>', '<Esc>')
map('x', '<', '<gv')
map('x', '>', '>gv')

map({ 'n', 'x' }, '<leader>p', '"+p', { desc = 'Paste clipboard' })
map('x', '<leader>y', '"+y', { desc = 'Copy to clipboard' })

if vim.g.vscode then
  return
end

for _, lhs in ipairs({ 'gra', 'gri', 'grn', 'grr', 'grt' }) do
  pcall(vim.keymap.del, 'n', lhs)
end

for _, lhs in ipairs({ '<C-w>d', '<C-w><C-d>' }) do
  pcall(vim.keymap.del, 'n', lhs)
end

map('n', '<C-w>', '<cmd>quit<cr>', { desc = 'Close window', nowait = true })
map('n', '<C-\\>', '<cmd>vsplit<cr>', { desc = 'Split right' })
map('n', '<C-->', '<cmd>split<cr>', { desc = 'Split below' })
map({ 'n', 'i', 'x', 's' }, '<C-s>', '<cmd>write<cr><Esc>', { desc = 'Save' })

map('n', '<C-Tab>', '<cmd>buffer #<cr>', { desc = 'Alternate buffer' })
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })
map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })

map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit all' })
map('n', '<leader>qf', '<cmd>qa!<cr>', { desc = 'Quit all, discard unsaved changes' })
map('n', '<leader>qs', '<cmd>wqa<cr>', { desc = 'Save all and quit' })

map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
map('x', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
map('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
map('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })

for key, severity in pairs({ d = false, e = 'ERROR', w = 'WARN' }) do
  for bracket, count in pairs({ ['['] = -1, [']'] = 1 }) do
    map('n', bracket .. key, function()
      vim.diagnostic.jump({
        count = count * vim.v.count1,
        severity = severity and vim.diagnostic.severity[severity] or nil,
        float = false,
      })
    end, { desc = (count == 1 and 'Next ' or 'Previous ') .. (severity or 'diagnostic') })
  end
end

map('n', '[q', '<cmd>cprevious<cr>', { desc = 'Previous quickfix' })
map('n', ']q', '<cmd>cnext<cr>', { desc = 'Next quickfix' })

map('n', '<leader>xq', function()
  if vim.fn.getqflist({ winid = 0 }).winid == 0 then
    vim.cmd.copen()
  else
    vim.cmd.cclose()
  end
end, { desc = 'Quickfix' })

map('n', '<leader>xl', function()
  if vim.fn.getloclist(0, { winid = 0 }).winid == 0 then
    vim.cmd.lopen()
  else
    vim.cmd.lclose()
  end
end, { desc = 'Location list' })
