return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      -- Map .razor files to the razor filetype so Blazor components are detected
      vim.filetype.add {
        extension = { razor = 'razor' },
      }

      -- Reuse the HTML parser for Razor buffers to get highlighting and indentation
      local language = vim.treesitter.language
      if language and language.register then
        language.register('html', 'razor')
      end

      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, 'html') then
        table.insert(opts.ensure_installed, 'html')
      end
    end,
  },
}
