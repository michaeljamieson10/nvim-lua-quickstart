return {
  {
    'kawre/leetcode.nvim',
    build = function()
      local ok = pcall(vim.cmd, 'TSInstall html')
      if not ok then
        print 'Failed to install Treesitter parser for HTML'
      end
    end,
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      lang = 'python3',
      use_treesitter = true,
    },
    config = function(_, opts)
      require('leetcode').setup(opts)
    end,
  },
}
