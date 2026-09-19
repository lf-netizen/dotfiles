local path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(path) then
  local result = vim
    .system(
      { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', path },
      { text = true }
    )
    :wait()

  if result.code ~= 0 then
    error(result.stderr)
  end
end

vim.opt.rtp:prepend(path)
require('lazy').setup({ { import = 'plugins' } }, {
  defaults = { lazy = false },
  change_detection = { notify = false },
  checker = { enabled = false },
})
