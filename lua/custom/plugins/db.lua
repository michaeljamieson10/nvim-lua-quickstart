return {
  -- SQL treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, lang in ipairs { 'sql' } do
        if not vim.tbl_contains(opts.ensure_installed, lang) then
          table.insert(opts.ensure_installed, lang)
        end
      end
    end,
  },

  -- Dadbod core + UI + completion
  {
    'tpope/vim-dadbod',
    lazy = true,
    cmd = { 'DB', 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer', 'DBUIRenameBuffer' },
    dependencies = {
      { 'kristijanhusak/vim-dadbod-ui', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql', 'pgsql' } },
      { 'tpope/vim-dotenv', lazy = true },
    },

    -- ✨ move everything from init -> config so it doesn't touch other buffers at startup
    config = function()
      -- nvim-dadbod-ui options
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_winwidth = 35
      vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/db_ui'

      -- Named connections via env
      vim.g.dbs = {
        dev = os.getenv 'PG_DEV_URL',
        prod = os.getenv 'PG_PROD_URL',
      }

      -- Dadbod completion only for SQL buffers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'sql', 'mysql', 'plsql', 'pgsql' },
        callback = function()
          local ok, cmp = pcall(require, 'cmp')
          if ok then
            cmp.setup.buffer {
              sources = cmp.config.sources({
                { name = 'vim-dadbod-completion' },
              }, {
                { name = 'buffer' },
              }),
            }
          end
        end,
      })

      -- Detect *.psql as sql
      vim.filetype.add { extension = { psql = 'sql' } }

      -- 🔒 safety guard: if anything marks Oil buffers readonly/nomodifiable, flip it back
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'oil',
        callback = function()
          vim.schedule(function()
            vim.bo.readonly = false
            vim.bo.modifiable = true
          end)
        end,
        desc = 'Ensure Oil buffers stay writable',
      })
    end,

    keys = {
      { '<leader>Du', '<cmd>DBUIToggle<cr>', desc = 'DB UI: Toggle' },
      { '<leader>Df', '<cmd>DBUIFindBuffer<cr>', desc = 'DB UI: Find Buffer' },
      { '<leader>Dr', '<cmd>DBUIRenameBuffer<cr>', desc = 'DB UI: Rename Buffer' },
      { '<leader>Dl', '<cmd>DBUILastQueryInfo<cr>', desc = 'DB UI: Last Query Info' },
    },
  },
}
