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
          -- For block wraps (e.g., Visual mode), place opening/closing on their own lines
          vim.bo[event.buf].commentstring = '{%- comment -%}\n%s\n{%- endcomment -%}'

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
      local lfmt = function(str, nodes)
        return fmt(str, nodes, { delimiters = '<>' })
      end
      local s = ls.snippet
      local i = ls.insert_node
      local t = ls.text_node

      ls.add_snippets('liquid', {
        s('lassign', fmt('{{%- assign {name} = {value} -%}}', {
          name = i(1, 'var_name'),
          value = i(2, 'value'),
        })),
        s('lif', fmt([[
{{%- if {cond} -%}}
    {body}
{{%- endif -%}}
]], {
          cond = i(1, 'condition'),
          body = i(0, 'body'),
        })),
        s('lfor', fmt([[
{{%- for {item} in {collection} -%}}
    {body}
{{%- endfor -%}}
]], {
          item = i(1, 'item'),
          collection = i(2, 'collection'),
          body = i(0, 'body'),
        })),
        s('lcapture', fmt([[
{{%- captureJson {name} -%}}
    {body}
{{%- endcaptureJson -%}}
]], {
          name = i(1, 'var_name'),
          body = i(0, '"key": "value"'),
        })),
        s('lnewarr', fmt('{{%- newArray {path} -%}}', {
          path = i(1, 'path.to.value'),
        })),
        s('lnewobj', fmt('{{%- newObject {name} -%}}', {
          name = i(1, 'varName'),
        })),
        s('lcomment', fmt([[
{{%- comment -%}}
    {body}
{{%- endcomment -%}}
]], {
          body = i(0, 'details'),
        })),
        s({ trig = '.assign', wordTrig = false }, lfmt('{%- assign <name> = <value> -%}', {
          name = i(1, 'var_name'),
          value = i(2, 'value'),
        })),
        s({ trig = '.capture', wordTrig = false }, lfmt([[
{%- capture <name> -%}
    <body>
{%- endcapture -%}
]], {
          name = i(1, 'var_name'),
          body = i(0, 'body'),
        })),
        s({ trig = '.comment', wordTrig = false }, lfmt([[
{%- comment -%}
    <body>
{%- endcomment -%}
]], {
          body = i(0, 'details'),
        })),
        s({ trig = '.if', wordTrig = false }, lfmt([[
{%- if <cond> -%}
    <body>
{%- endif -%}
]], {
          cond = i(1, 'condition'),
          body = i(0, 'body'),
        })),
        s({ trig = '.elsif', wordTrig = false }, lfmt('{%- elsif <cond> -%}', {
          cond = i(1, 'condition'),
        })),
        s({ trig = '.else', wordTrig = false }, t '{%- else -%}'),
        s({ trig = '.unless', wordTrig = false }, lfmt([[
{%- unless <cond> -%}
    <body>
{%- endunless -%}
]], {
          cond = i(1, 'condition'),
          body = i(0, 'body'),
        })),
        s({ trig = '.case', wordTrig = false }, lfmt([[
{%- case <expr> -%}
    {%- when <value> -%}
        <body>
{%- endcase -%}
]], {
          expr = i(1, 'expression'),
          value = i(2, 'value'),
          body = i(0, 'body'),
        })),
        s({ trig = '.when', wordTrig = false }, lfmt('{%- when <value> -%}', {
          value = i(1, 'value'),
        })),
        s({ trig = '.for', wordTrig = false }, lfmt([[
{%- for <item> in <collection> -%}
    <body>
{%- endfor -%}
]], {
          item = i(1, 'item'),
          collection = i(2, 'collection'),
          body = i(0, 'body'),
        })),
        s({ trig = '.tablerow', wordTrig = false }, lfmt([[
{%- tablerow <item> in <collection> <params> -%}
    <body>
{%- endtablerow -%}
]], {
          item = i(1, 'item'),
          collection = i(2, 'collection'),
          params = i(3, 'cols: 4'),
          body = i(0, 'body'),
        })),
        s({ trig = '.cycle', wordTrig = false }, lfmt('{%- cycle <values> -%}', {
          values = i(1, "'one', 'two'"),
        })),
        s({ trig = '.break', wordTrig = false }, t '{%- break -%}'),
        s({ trig = '.continue', wordTrig = false }, t '{%- continue -%}'),
        s({ trig = '.increment', wordTrig = false }, lfmt('{%- increment <name> -%}', {
          name = i(1, 'counter'),
        })),
        s({ trig = '.decrement', wordTrig = false }, lfmt('{%- decrement <name> -%}', {
          name = i(1, 'counter'),
        })),
        s({ trig = '.echo', wordTrig = false }, lfmt('{%- echo <value> -%}', {
          value = i(1, 'value'),
        })),
        s({ trig = '.raw', wordTrig = false }, lfmt([[
{%- raw -%}
    <body>
{%- endraw -%}
]], {
          body = i(0, 'body'),
        })),
        s({ trig = '.liquid', wordTrig = false }, lfmt([[
{%- liquid
    <lines>
-%}
]], {
          lines = i(0, 'assign foo = \"bar\"'),
        })),
        s({ trig = '.render', wordTrig = false }, lfmt("{%- render '<snippet>' -%}", {
          snippet = i(1, 'snippet'),
        })),
        s({ trig = '.include', wordTrig = false }, lfmt("{%- include '<snippet>' -%}", {
          snippet = i(1, 'snippet'),
        })),
        s({ trig = '.section', wordTrig = false }, lfmt("{%- section '<name>' -%}", {
          name = i(1, 'name'),
        })),
        s({ trig = '.sections', wordTrig = false }, lfmt("{%- sections '<name>' -%}", {
          name = i(1, 'name'),
        })),
        s({ trig = '.layout', wordTrig = false }, lfmt("{%- layout '<name>' -%}", {
          name = i(1, 'name'),
        })),
        s({ trig = '.style', wordTrig = false }, lfmt([[
{%- style -%}
    <body>
{%- endstyle -%}
]], {
          body = i(0, 'body'),
        })),
        s({ trig = '.stylesheet', wordTrig = false }, lfmt([[
{%- stylesheet -%}
    <body>
{%- endstylesheet -%}
]], {
          body = i(0, 'body'),
        })),
        s({ trig = '.javascript', wordTrig = false }, lfmt([[
{%- javascript -%}
    <body>
{%- endjavascript -%}
]], {
          body = i(0, 'body'),
        })),
        s({ trig = '.form', wordTrig = false }, lfmt([[
{%- form '<type>', <object> -%}
    <body>
{%- endform -%}
]], {
          type = i(1, 'form_type'),
          object = i(2, 'object'),
          body = i(0, 'body'),
        })),
        s({ trig = '.paginate', wordTrig = false }, lfmt([[
{%- paginate <collection> by <size> -%}
    <body>
{%- endpaginate -%}
]], {
          collection = i(1, 'collection'),
          size = i(2, '20'),
          body = i(0, 'body'),
        })),
        s({ trig = '.content_for', wordTrig = false }, lfmt("{%- content_for '<name>' -%}", {
          name = i(1, 'name'),
        })),
        s({ trig = '.doc', wordTrig = false }, lfmt([[
{%- doc -%}
    <body>
{%- enddoc -%}
]], {
          body = i(0, 'details'),
        })),
      })
    end,
  },
}
