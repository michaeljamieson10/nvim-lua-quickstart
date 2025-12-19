return {
  {
    dir = vim.fn.stdpath('config') .. '/local_plugins/bruno.nvim',
    name = 'bruno.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      { '<leader>bb', '<cmd>BrunoRun<CR>', desc = 'Bruno: Run request' },
      { '<leader>be', '<cmd>BrunoEnvFilePick<CR>', desc = 'Bruno: Pick env file (bruno_custom)' },
      { '<leader>bE', '<cmd>BrunoEnvFromFile<CR>', desc = 'Bruno: Env from current file' },
    },
    config = function()
      require('bruno').setup {
        collection_paths = {},
        picker = 'telescope',
        env_file_root = vim.fn.expand '~/Code/bruno_custom/envs',
      }
    end,
  },
}
