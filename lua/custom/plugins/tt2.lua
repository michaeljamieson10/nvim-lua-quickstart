local M = {}

function M.setup()
  local ls = require 'luasnip'
  ls.add_snippets('tt2', {
    ls.parser.parse_snippet(
      'if',
      [[
IF ${1:condition};
    ${0}
END;
]]
    ),
    ls.parser.parse_snippet(
      'foreach',
      [[
FOR ${1:item} IN ${2:list};
    ${0}
END;
]]
    ),
    ls.parser.parse_snippet(
      'block',
      [[
BLOCK ${1:block_name};
    ${0}
END;
]]
    ),
  })
end

return {
  -- Filetype detection for .tt files
  vim.filetype.add {
    extension = {
      tt = 'tt2', -- Associate .tt files with tt2 filetype
    },
  },

  -- Syntax highlighting rules
  vim.cmd [[
    syntax keyword ttKeyword FOR IN IF ELSE ELSIF UNLESS END BLOCK INCLUDE PROCESS WRAPPER
    syntax match ttVariable /\$[a-zA-Z_][a-zA-Z0-9_]*/

    highlight link ttKeyword Keyword
    highlight link ttFunction Function
    highlight link ttVariable Identifier
  ]],

  -- Indentation rules
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'tt2',
    callback = function()
      vim.opt_local.expandtab = true -- Use spaces instead of tabs
      vim.opt_local.shiftwidth = 4 -- Indentation width
      vim.opt_local.tabstop = 4 -- Tab width

      -- Indent after FOR and IF, unindent after END
      vim.opt_local.smartindent = true
    end,
  }),

  -- Snippet setup
  M.setup(),
}
