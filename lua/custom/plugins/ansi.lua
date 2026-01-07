return {
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup { 'log' }
    end,
  },
  {
    'm00qek/baleia.nvim',
    version = '*',
    config = function()
      vim.g.baleia = require('baleia').setup {}

      -- Create command for manual colorization
      vim.api.nvim_create_user_command('BaleiaColorize', function()
        vim.g.baleia.once(vim.api.nvim_get_current_buf())
      end, { bang = true, desc = 'Colorize ANSI escape sequences' })

      vim.api.nvim_create_user_command('BaleiaLogs', vim.g.baleia.logger.show, { bang = true, desc = 'Show Baleia logs' })

      -- Automatically colorize when log filetype is set
      local augroup = vim.api.nvim_create_augroup('BaleiaAutocolor', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = augroup,
        pattern = 'log',
        callback = function()
          vim.schedule(function()
            vim.g.baleia.once(vim.api.nvim_get_current_buf())
          end)
        end,
      })
    end,
  },
}
