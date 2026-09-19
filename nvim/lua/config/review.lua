local M = {}

local function git(args, cwd)
  local cmd = { 'git', '-C', cwd or require('config.project').root() }
  vim.list_extend(cmd, args)
  local result = vim.system(cmd, { text = true }):wait()

  if result.code ~= 0 then
    return nil, vim.trim(result.stderr)
  end

  return vim.trim(result.stdout)
end

function M.branch()
  local root, err = git({ 'rev-parse', '--show-toplevel' })

  if not root then
    vim.notify(err, vim.log.levels.WARN)
    return
  end
  local base = git({ 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD' }, root)

  vim.ui.input({ prompt = 'Review base: ', default = base or '' }, function(value)
    if not value or value == '' then
      return
    end
    local revision = git({ 'rev-parse', '--verify', '--end-of-options', value .. '^{commit}' }, root)
    if not revision then
      vim.notify('Unknown base: ' .. value, vim.log.levels.ERROR)
      return
    end
    vim.cmd({ cmd = 'CodeDiff', args = { '--repo', root, revision .. '...HEAD' } })
  end)
end

function M.worktree()
  local output, err = git({ 'worktree', 'list', '--porcelain', '-z' })

  if not output then
    vim.notify(err, vim.log.levels.WARN)
    return
  end
  local paths = {}

  for field in output:gmatch('[^%z]+') do
    if field:sub(1, 9) == 'worktree ' then
      paths[#paths + 1] = field:sub(10)
    end
  end

  vim.ui.select(paths, { prompt = 'Review worktree' }, function(path)
    if path then
      vim.cmd({ cmd = 'CodeDiff', args = { '--repo', path } })
    end
  end)
end

return M
