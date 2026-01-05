vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.log',
  callback = function()
    vim.bo.filetype = 'log'
    -- Enable concealment to hide ANSI codes
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = 'nc'

    -- Auto-reload without prompting
    vim.bo.autoread = true

    -- Apply baleia immediately after setting filetype
    vim.schedule(function()
      local ok, baleia = pcall(require, 'baleia')
      if ok and vim.g.baleia then
        vim.g.baleia.automatically(vim.api.nvim_get_current_buf())
      end
    end)
  end,
})

-- Check for file changes periodically
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  pattern = '*.log',
  callback = function()
    vim.cmd('checktime')
  end,
})
