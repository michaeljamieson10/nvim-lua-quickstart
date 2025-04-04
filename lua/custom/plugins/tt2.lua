-- This configures your local Treesitter parser for tt2
return {
  'nvim-treesitter/nvim-treesitter',
  opts = function(_, opts)
    local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    parser_config.tt2 = {
      install_info = {
    url = vim.fn.stdpath('config') .. '/lua/custom/tree-sitter-tt2', -- local path, NOT git url
    files = { 'src/parser.c' },
    generate_requires_npm = false, -- 🛑 important
    requires_generate_from_grammar = false, -- 🛑 important
    branch = 'main', -- dummy, needed by treesitter
  },
  filetype = 'tt2',
}

    vim.filetype.add {
      extension = {
        tt = 'tt2',
      },
    }

    -- Ensure tt2 gets installed if you use :TSInstall
    if type(opts.ensure_installed) == 'table' then
      vim.list_extend(opts.ensure_installed, { 'tt2' })
    end
  end,
}

