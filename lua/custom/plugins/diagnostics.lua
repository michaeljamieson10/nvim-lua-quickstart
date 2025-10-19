return {
  {
    'dmmulroy/ts-error-translator.nvim',
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    config = function()
      require('ts-error-translator').setup()
    end,
  },
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Trouble: Toggle workspace diagnostics' },
      { '<leader>xb', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Trouble: Buffer diagnostics' },
      { '<leader>xs', '<cmd>Trouble symbols toggle win.position=right<cr>', desc = 'Trouble: Symbols' },
    },
  },
  {
    'maan2003/lsp_lines.nvim',
    event = 'VeryLazy',
    config = function()
      require('lsp_lines').setup()

      vim.diagnostic.config {
        severity_sort = true,
        update_in_insert = false,
        underline = true,
        signs = true,
        virtual_text = { prefix = '●', spacing = 1, source = 'if_many' },
        float = { border = 'rounded', source = 'if_many', focusable = false },
      }

      local border = 'rounded'
      local orig = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or border
        return orig(contents, syntax, opts, ...)
      end

      local group = vim.api.nvim_create_augroup('custom-diag-hover', { clear = true })
      local enabled = true

      local function enable_hover()
        vim.api.nvim_create_autocmd('CursorHold', {
          group = group,
          callback = function()
            local mode = vim.api.nvim_get_mode().mode
            if mode:sub(1, 1) ~= 'n' or vim.bo.buftype == 'terminal' then
              return
            end
            vim.diagnostic.open_float(nil, { border = 'rounded', focusable = false, scope = 'cursor' })
          end,
        })
        enabled = true
      end

      local function disable_hover()
        vim.api.nvim_clear_autocmds { group = group }
        enabled = false
      end

      enable_hover()

      vim.keymap.set('n', '<leader>tf', function()
        if enabled then
          disable_hover()
          print 'Diagnostic hover: OFF'
        else
          enable_hover()
          print 'Diagnostic hover: ON'
        end
      end, { desc = '[T]oggle diagnostic [F]loat' })
    end,
  },
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
}
