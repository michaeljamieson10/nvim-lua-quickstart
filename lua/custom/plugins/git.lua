return {
  {
    'kdheepak/lazygit.nvim',
    cmd = 'LazyGit',
    keys = {
      { '<leader>lg', '<cmd>LazyGit<CR>', desc = 'Open Lazygit' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
    keys = {
      { '<leader>dv', ':DiffviewOpen<CR>', desc = 'Open Diffview' },
      { '<leader>dc', ':DiffviewClose<CR>', desc = 'Close Diffview' },
      { '<leader>df', ':DiffviewToggleFiles<CR>', desc = 'Toggle Diffview Files' },
      { '<leader>dq', ':DiffviewFocusFiles<CR>', desc = 'Focus Diffview Files' },
      { '<leader>dp', ':DiffviewOpen HEAD^<CR>', desc = 'Diff Previous Commit' },
      { '<leader>db', ':DiffviewOpen origin/development...HEAD<CR>', desc = 'Diff Branch vs development' },
    },
    config = function()
      require('diffview').setup {
        enhanced_diff_hl = true,
        use_icons = true,
      }
    end,
  },
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Git blame' },
    keys = {
      { '<leader>gb', ':Git blame<CR>', desc = 'Git Blame' },
    },
  },
  {
    'ruifm/gitlinker.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('gitlinker').setup {
        opts = {
          add_current_line = true,
          action_callback = function(url)
            vim.fn.setreg('+', url)
            print('Copied URL to clipboard: ' .. url)
          end,
          print_url = true,
        },
      }

      vim.keymap.set('n', '<leader>gl', function()
        require('gitlinker').get_buf_range_url 'n'
      end, { noremap = true, silent = true, desc = 'GitLinker: Copy repo link for current file/line' })
    end,
  },
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('octo').setup()
    end,
  },
}
