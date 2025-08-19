-- lua/plugins/db.lua  (or paste this block alongside your other plugin specs)
return {

  -- SQL treesitter (nice highlighting for psql)
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, lang in ipairs { 'sql' } do -- only "sql", no "pgsql"
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
      -- optional: load .env so DB URLs can live there
      { 'tpope/vim-dotenv', lazy = true },
    },
    init = function()
      -- nvim-dadbod-ui options (tweak to taste)
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_winwidth = 35
      vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/db_ui'

      -- Named connections (pick up from env so you don't commit secrets)
      -- Put these in your shell env or a project .env:
      --   PG_DEV_URL='postgresql://user:pass@localhost:5432/mydb?sslmode=disable'
      --   PG_PROD_URL='postgresql://user:pass@host:5432/proddb'
      vim.g.dbs = {
        dev = os.getenv 'PG_DEV_URL',
        prod = os.getenv 'PG_PROD_URL',
      }

      -- nvim-cmp source for dadbod (buffer-local when editing SQL)
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

      -- Make *.psql / *.sql detected as sql for completion/highlight
      vim.filetype.add {
        extension = { psql = 'sql' },
      }
    end,
    keys = {
      { '<leader>Du', '<cmd>DBUIToggle<cr>', desc = 'DB UI: Toggle' },
      { '<leader>Df', '<cmd>DBUIFindBuffer<cr>', desc = 'DB UI: Find Buffer' },
      { '<leader>Dr', '<cmd>DBUIRenameBuffer<cr>', desc = 'DB UI: Rename Buffer' },
      { '<leader>Dl', '<cmd>DBUILastQueryInfo<cr>', desc = 'DB UI: Last Query Info' },
    },
  },
}
