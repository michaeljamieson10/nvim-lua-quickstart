local M = {}

function M.setup()
  local ls = require 'luasnip'
  ls.add_snippets('tt2', {
    ls.parser.parse_snippet('if', '[% IF ${1:condition} %]\n\t${0}\n[% END %]'),
    ls.parser.parse_snippet('foreach', '[% FOREACH ${1:item} IN ${2:list} %]\n\t${0}\n[% END %]'),
    ls.parser.parse_snippet('block', '[% BLOCK ${1:block_name} %]\n\t${0}\n[% END %]'),
  })
end

return {
  vim.filetype.add {
    extension = {
      tt = 'tt2', -- Associate .tt files with tt2 filetype
    },
  },
  vim.cmd [[
            syntax keyword ttKeyword FOR IF ELSE ELSIF UNLESS END
            syntax keyword ttFunction INCLUDE PROCESS WRAPPER
            syntax match ttVariable /\$[a-zA-Z_][a-zA-Z0-9_]*/

            highlight link ttKeyword Keyword
            highlight link ttFunction Function
            highlight link ttVariable Identifier
        ]],
}
