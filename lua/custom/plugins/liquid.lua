-- Liquid template helpers and style defaults
return {
  -- Basic syntax/filetype support
  {
    'tpope/vim-liquid',
    event = { 'BufReadPre', 'BufNewFile' },
  },

  -- Treesitter integration + filetype/local options
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      vim.filetype.add {
        extension = {
          liquid = 'liquid',
        },
      }

      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, 'liquid') then
        table.insert(opts.ensure_installed, 'liquid')
      end

      local liquid_group = vim.api.nvim_create_augroup('liquid-style-guide', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = liquid_group,
        pattern = 'liquid',
        desc = 'Company Liquid style: 4-space indent and whitespace hygiene',
        callback = function(event)
          local opt = vim.opt_local
          opt.expandtab = true
          opt.tabstop = 4
          opt.shiftwidth = 4
          opt.softtabstop = 4
          opt.wrap = false
          opt.breakindent = true

          -- Align comment operators with the required Liquid block form
          vim.bo[event.buf].commentstring = '{%%- comment %%} %s {%%- endcomment %%}'

          -- Preserve readable spacing while avoiding useless trailing blanks
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = liquid_group,
            buffer = event.buf,
            command = 'keepjumps keeppatterns %s/\\s\\+$//e',
            desc = 'Trim trailing whitespace in Liquid files',
          })
        end,
      })
    end,
  },

  -- Handy Liquid snippets
  {
    'L3MON4D3/LuaSnip',
    event = 'InsertEnter',
    config = function()
      local ls = require 'luasnip'
      local fmt = require('luasnip.extras.fmt').fmt
      local s = ls.snippet
      local i = ls.insert_node

      ls.add_snippets('liquid', {
        s('lassign', fmt('{%%- assign {name} = {value} %%}', {
          name = i(1, 'var_name'),
          value = i(2, 'value'),
        })),
        s('lif', fmt([[
{%%- if {cond} -%%}
    {body}
{%%- endif -%%}
]], {
          cond = i(1, 'condition'),
          body = i(0, 'body'),
        })),
        s('lfor', fmt([[
{%%- for {item} in {collection} -%%}
    {body}
{%%- endfor -%%}
]], {
          item = i(1, 'item'),
          collection = i(2, 'collection'),
          body = i(0, 'body'),
        })),
        s('lcapture', fmt([[
{%%- captureJson {name} -%%}
    {body}
{%%- endcaptureJson -%%}
]], {
          name = i(1, 'var_name'),
          body = i(0, '"key": "value"'),
        })),
        s('lnewarr', fmt('{%%- newArray {path} -%%}', {
          path = i(1, 'path.to.value'),
        })),
        s('lnewobj', fmt('{%%- newObject {name} -%%}', {
          name = i(1, 'varName'),
        })),
        s('lcomment', fmt([[
{%%- comment -%%}
    {body}
{%%- endcomment -%%}
]], {
          body = i(0, 'details'),
        })),
      })
    end,
  },
}
