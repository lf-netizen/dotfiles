require('lazy').setup({

  { import = 'plugins.core' }, -- aka just for editing / navigation. Can use Ctrl.
  { import = 'plugins.addons' }, -- aka the rest. Uses leader as base.
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = {},
  },
})

-- vim: ts=2 sts=2 sw=2 et
