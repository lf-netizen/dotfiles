vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.scrolloff = 10

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.inccommand = 'split'
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.timeoutlen = 300
vim.opt.updatetime = 200

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('state') .. '/undo'
vim.opt.swapfile = false
vim.opt.backup = false

if not vim.g.vscode then
  vim.opt.termguicolors = true
  vim.opt.showmode = false
  vim.opt.signcolumn = 'yes:2'
  vim.opt.winborder = 'rounded'
  vim.opt.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
  vim.opt.laststatus = 3
  vim.opt.statusline = '%{%v:lua.require("config.statusline").render()%}'
end
