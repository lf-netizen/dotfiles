local M = {}

function M.root(buf)
  return vim.fs.root(buf or 0, { '.git', 'pyproject.toml', 'package.json' }) or vim.fn.getcwd()
end

function M.python(buf)
  local root = M.root(buf)

  for _, path in ipairs({ root .. '/.venv/bin/python', root .. '/venv/bin/python' }) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  return vim.fn.exepath('python3')
end

function M.command(name, buf)
  local root = M.root(buf)

  for _, path in ipairs({ root .. '/.venv/bin/' .. name, root .. '/node_modules/.bin/' .. name }) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  return name
end

return M
