local M = {}
local ns = vim.api.nvim_create_namespace('ExpandedDiagnostics')

function M.setup()
  vim.diagnostic.config({
    severity_sort = true,
    virtual_lines = false,
    virtual_text = {
      spacing = 2,
      source = 'if_many',
      format = function(d)
        return d.message:gsub('%s+', ' ')
      end,
    },
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = { text = { [1] = '󰅚 ', [2] = '󰀪 ', [3] = '󰋽 ', [4] = '󰌶 ' } },
  })

  vim.keymap.set('n', 'X', function()
    local buf, row = vim.api.nvim_get_current_buf(), vim.api.nvim_win_get_cursor(0)[1] - 1
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    local lines = {}
    local groups = { 'DiagnosticError', 'DiagnosticWarn', 'DiagnosticInfo', 'DiagnosticHint' }
    for _, d in ipairs(vim.diagnostic.get(buf, { lnum = row })) do
      for _, line in ipairs(vim.split(d.message, '\n')) do
        lines[#lines + 1] = { { '  ' .. line, groups[d.severity] } }
      end
    end
    if #lines > 0 then
      vim.api.nvim_buf_set_extmark(buf, ns, row, 0, { virt_lines = lines })
    end
  end, { desc = 'Expand line diagnostics' })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufLeave', 'DiagnosticChanged' }, {
    group = vim.api.nvim_create_augroup('ExpandedDiagnostics', { clear = true }),
    callback = function(event)
      vim.api.nvim_buf_clear_namespace(event.buf, ns, 0, -1)
    end,
  })
end

return M
