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

-- Suppress the reload prompt and reload automatically
vim.api.nvim_create_autocmd('FileChangedShell', {
  pattern = '*.log',
  callback = function()
    -- Auto-reload: tell Vim to load the file
    vim.v.fcs_choice = 'reload'
  end,
})

-- Check for file changes on these events
vim.api.nvim_create_autocmd({ 'CursorHold', 'FocusGained', 'BufEnter' }, {
  pattern = '*.log',
  callback = function()
    vim.cmd('checktime')
  end,
})

-- Auto-scroll to bottom and reapply colors after reload
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  pattern = '*.log',
  callback = function()
    -- Scroll to bottom
    vim.cmd('normal! G')
    -- Reapply syntax colors
    vim.schedule(function()
      if vim.g.baleia then
        vim.g.baleia.once(vim.api.nvim_get_current_buf())
      end
    end)
  end,
})

-- Apply colors on initial read
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = '*.log',
  callback = function()
    vim.schedule(function()
      if vim.g.baleia then
        vim.g.baleia.once(vim.api.nvim_get_current_buf())
      end
    end)
  end,
})
