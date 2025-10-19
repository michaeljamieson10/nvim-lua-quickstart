return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    opts = {
      skip_confirm_for_simple_edits = true,
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },
    },
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    keys = {
      { '<leader>o', ':Oil<CR>', desc = 'Open Oil File Explorer' },
      { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' },
    },
  },
  {
    'cameron-wags/rainbow_csv.nvim',
    config = true,
    ft = { 'csv', 'tsv', 'csv_pipe', 'csv_semicolon' },
    cmd = { 'RainbowDelim', 'Select', 'Update', 'RBQL' },
  },
}
