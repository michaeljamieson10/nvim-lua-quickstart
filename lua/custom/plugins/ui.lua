return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'gruvbox',
        icons_enabled = vim.g.have_nerd_font,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
    },
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      vim.g.gruvbox_contrast_dark = 'hard'
      vim.opt.background = 'dark'
      vim.cmd.colorscheme 'gruvbox'
    end,
  },
}
