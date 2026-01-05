vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.log',
  callback = function()
    vim.bo.filetype = 'log'
    -- Enable concealment to hide ANSI codes
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = 'nc'
    -- Auto-reload without prompting
    vim.bo.autoread = true
  end,
})

-- Check for file changes periodically and trigger reload
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI', 'FocusGained' }, {
  pattern = '*.log',
  callback = function()
    vim.cmd('checktime')
  end,
})

-- Reapply baleia colors after any buffer read/reload
vim.api.nvim_create_autocmd({ 'BufReadPost', 'FileChangedShellPost' }, {
  pattern = '*.log',
  callback = function()
    vim.schedule(function()
      if vim.g.baleia then
        vim.g.baleia.once(vim.api.nvim_get_current_buf())
      end
    end)
  end,
})
