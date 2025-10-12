vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

if vim.g.vscode then
  require 'vsc'
else
  require 'keymaps'
  require 'options'

  require 'lazy-bootstrap'
  require 'lazy-plugins'
end
