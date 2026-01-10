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

      opts.highlight = opts.highlight or {}
      if type(opts.highlight.disable) == 'table' then
        if not vim.tbl_contains(opts.highlight.disable, 'liquid') then
          table.insert(opts.highlight.disable, 'liquid')
        end
      elseif opts.highlight.disable == nil then
        opts.highlight.disable = { 'liquid' }
      end

      local liquid_group = vim.api.nvim_create_augroup('liquid-style-guide', { clear = true })
      local function set_liquid_highlights()
        vim.api.nvim_set_hl(0, '@keyword.operator.liquid', { link = 'Keyword' })
      end

      set_liquid_highlights()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = liquid_group,
        desc = 'Ensure Liquid keyword operators stay visible',
        callback = set_liquid_highlights,
      })
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
          vim.bo[event.buf].commentstring = '{% comment %}\n%s\n{% endcomment %}'

          -- Configure autopairs for Liquid to ensure { closes with }
          local ok, autopairs = pcall(require, 'nvim-autopairs')
          if ok then
            local Rule = require 'nvim-autopairs.rule'
            -- Add a rule to close single { with }
            autopairs.add_rules({
              Rule('{', '}'):with_pair(function(pair_opts)
                -- Only pair if not followed by { or %
                local next_char = pair_opts.line:sub(pair_opts.col, pair_opts.col)
                return next_char ~= '{' and next_char ~= '%'
              end),
            })
          end

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
        return fmt(str, nodes, { delimiters = '<>', repeat_duplicates = true })
      end
      local s = ls.snippet
      local i = ls.insert_node
      local t = ls.text_node
      local c = ls.choice_node
      local f = ls.function_node
      local function trim(text)
        return (text:gsub('^%s+', ''):gsub('%s+$', ''))
      end

      local function liquid_log_value()
        local ok, clip = pcall(vim.fn.getreg, '+')
        if not ok or type(clip) ~= 'string' or clip == '' then
          return 'value'
        end

        clip = trim(clip)
        if clip == '' then
          return 'value'
        end

        local inner = clip:match('^{{%-?%s*([%s%S]-)%s*%-?}}$')
        if inner then
          clip = trim(inner)
        end

        inner = clip:match('^([%s%S]-)%s*|%s*stringifyObj%s*$')
        if inner then
          clip = trim(inner)
        end

        if clip == '' then
          return 'value'
        end

        return clip
      end

      ls.add_snippets('liquid', {
        s({ trig = '.assign', wordTrig = false }, lfmt('{%<ltrim> assign <name> = <value> <rtrim>%}', {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          name = i(3, 'var_name'),
          value = i(4, 'value'),
        })),
        s({ trig = '.capture', wordTrig = false }, lfmt([[
{%<ltrim> capture <name> <rtrim>%}
    <body>
{%<ltrim> endcapture <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          name = i(3, 'var_name'),
          body = i(0, 'body'),
        })),
        s({ trig = '.captureJson', wordTrig = false }, lfmt([[
{%- captureJson <name> %}
    <body>
    {%- endcapture %}
]], {
          name = i(1, 'var_name'),
          body = i(0, 'body'),
        })),
        s({ trig = '.comment', wordTrig = false }, lfmt([[
{%<ltrim> comment <rtrim>%}
    <body>
{%<ltrim> endcomment <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          body = i(0, 'details'),
        })),
        s({ trig = '.if', wordTrig = false }, lfmt([[
{%<ltrim> if <cond> <rtrim>%}
    <body>
{%<ltrim> endif <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          cond = i(3, 'condition'),
          body = i(0, 'body'),
        })),
        s({ trig = '.elsif', wordTrig = false }, lfmt('{%<ltrim> elsif <cond> <rtrim>%}', {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          cond = i(3, 'condition'),
        })),
        s({ trig = '.else', wordTrig = false }, lfmt('{%<ltrim> else <rtrim>%}', {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
        })),
        s({ trig = '.unless', wordTrig = false }, lfmt([[
{%<ltrim> unless <cond> <rtrim>%}
    <body>
{%<ltrim> endunless <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          cond = i(3, 'condition'),
          body = i(0, 'body'),
        })),
        s({ trig = '.case', wordTrig = false }, lfmt([[
{%<ltrim> case <expr> <rtrim>%}
    {%<ltrim> when <value> <rtrim>%}
        <body>
{%<ltrim> endcase <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          expr = i(3, 'expression'),
          value = i(4, 'value'),
          body = i(0, 'body'),
        })),
        s({ trig = '.when', wordTrig = false }, lfmt('{%<ltrim> when <value> <rtrim>%}', {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          value = i(3, 'value'),
        })),
        s({ trig = '.for', wordTrig = false }, lfmt([[
{%<ltrim> for <item> in <collection> <rtrim>%}
    <body>
{%<ltrim> endfor <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          item = i(3, 'item'),
          collection = i(4, 'collection'),
          body = i(0, 'body'),
        })),
        s({ trig = '.tablerow', wordTrig = false }, lfmt([[
{%<ltrim> tablerow <item> in <collection> <params> <rtrim>%}
    <body>
{%<ltrim> endtablerow <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          item = i(3, 'item'),
          collection = i(4, 'collection'),
          params = i(5, 'cols: 4'),
          body = i(0, 'body'),
        })),
        s({ trig = '.cycle', wordTrig = false }, lfmt('{%<ltrim> cycle <values> <rtrim>%}', {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          values = i(3, "'one', 'two'"),
        })),
        s({ trig = '.break', wordTrig = false }, lfmt('{%<ltrim> break <rtrim>%}', {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
        })),
        s({ trig = '.continue', wordTrig = false }, lfmt('{%<ltrim> continue <rtrim>%}', {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
        })),
        s({ trig = '.increment', wordTrig = false }, lfmt('{%<ltrim> increment <name> <rtrim>%}', {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          name = i(3, 'counter'),
        })),
        s({ trig = '.decrement', wordTrig = false }, lfmt('{%<ltrim> decrement <name> <rtrim>%}', {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          name = i(3, 'counter'),
        })),
        s({ trig = '.echo', wordTrig = false }, lfmt('{%<ltrim> echo <value> <rtrim>%}', {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          value = i(3, 'value'),
        })),
        s({ trig = '.raw', wordTrig = false }, lfmt([[
{%<ltrim> raw <rtrim>%}
    <body>
{%<ltrim> endraw <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          body = i(0, 'body'),
        })),
        s({ trig = '.liquid', wordTrig = false }, lfmt([[
{%<ltrim> liquid
    <lines>
<rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          lines = i(0, 'assign foo = \"bar\"'),
        })),
        s({ trig = '.render', wordTrig = false }, lfmt("{%<ltrim> render '<snippet>' <rtrim>%}", {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          snippet = i(3, 'snippet'),
        })),
        s({ trig = '.include', wordTrig = false }, lfmt("{%<ltrim> include '<snippet>' <rtrim>%}", {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          snippet = i(3, 'snippet'),
        })),
        s({ trig = '.section', wordTrig = false }, lfmt("{%<ltrim> section '<name>' <rtrim>%}", {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          name = i(3, 'name'),
        })),
        s({ trig = '.sections', wordTrig = false }, lfmt("{%<ltrim> sections '<name>' <rtrim>%}", {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          name = i(3, 'name'),
        })),
        s({ trig = '.layout', wordTrig = false }, lfmt("{%<ltrim> layout '<name>' <rtrim>%}", {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          name = i(3, 'name'),
        })),
        s({ trig = '.style', wordTrig = false }, lfmt([[
{%<ltrim> style <rtrim>%}
    <body>
{%<ltrim> endstyle <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          body = i(0, 'body'),
        })),
        s({ trig = '.stylesheet', wordTrig = false }, lfmt([[
{%<ltrim> stylesheet <rtrim>%}
    <body>
{%<ltrim> endstylesheet <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          body = i(0, 'body'),
        })),
        s({ trig = '.javascript', wordTrig = false }, lfmt([[
{%<ltrim> javascript <rtrim>%}
    <body>
{%<ltrim> endjavascript <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          body = i(0, 'body'),
        })),
        s({ trig = '.form', wordTrig = false }, lfmt([[
{%<ltrim> form '<type>', <object> <rtrim>%}
    <body>
{%<ltrim> endform <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          type = i(3, 'form_type'),
          object = i(4, 'object'),
          body = i(0, 'body'),
        })),
        s({ trig = '.paginate', wordTrig = false }, lfmt([[
{%<ltrim> paginate <collection> by <size> <rtrim>%}
    <body>
{%<ltrim> endpaginate <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          collection = i(3, 'collection'),
          size = i(4, '20'),
          body = i(0, 'body'),
        })),
        s({ trig = '.content_for', wordTrig = false }, lfmt("{%<ltrim> content_for '<name>' <rtrim>%}", {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          name = i(3, 'name'),
        })),
        s({ trig = '.doc', wordTrig = false }, lfmt([[
{%<ltrim> doc <rtrim>%}
    <body>
{%<ltrim> enddoc <rtrim>%}
]], {
          ltrim = c(1, { t '', t '-' }),
          rtrim = c(2, { t '', t '-' }),
          body = i(0, 'details'),
        })),
        s({ trig = '.log', wordTrig = false }, lfmt('{{ <value> | stringifyObj }}', {
          value = f(liquid_log_value, {}),
        })),
      })
    end,
  },
}
