local M = {}

local diagnostics = {
  { vim.diagnostic.severity.ERROR, '󰅚', 'DiagnosticError' },
  { vim.diagnostic.severity.WARN, '󰀪', 'DiagnosticWarn' },
  { vim.diagnostic.severity.INFO, '󰋽', 'DiagnosticInfo' },
  { vim.diagnostic.severity.HINT, '󰌶', 'DiagnosticHint' },
}

function M.render()
  -- Gitsigns keeps the branch cached; never run Git during a screen redraw.
  local branch = vim.b.gitsigns_head or ''
  local left = branch ~= '' and ('%#StatusLineBranch# ' .. branch:gsub('%%', '%%%%') .. '  %#StatusLine#') or ''
  local parts = { '%#StatusLine# ' .. left .. '%<%f%=' }
  local counts = vim.diagnostic.count(0)

  for _, diagnostic in ipairs(diagnostics) do
    local severity, icon, highlight = unpack(diagnostic)
    local count = counts[severity] or 0

    if count > 0 then
      parts[#parts + 1] = ('%%#%s#%s %d  '):format(highlight, icon, count)
    end
  end

  parts[#parts + 1] = '%#StatusLine#%l:%c '

  return table.concat(parts)
end

return M
