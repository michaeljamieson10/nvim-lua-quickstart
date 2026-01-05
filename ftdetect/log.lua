-- Helper function to apply baleia colors
local function apply_baleia_colors()
  vim.schedule(function()
    if vim.g.baleia then
      -- Clear any existing highlights first
      vim.g.baleia.once(vim.api.nvim_get_current_buf())
    end
  end)
end

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

-- Apply colors whenever buffer is read (including reloads)
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*.log',
  callback = function()
    apply_baleia_colors()
  end,
})

-- Reapply colors after external file changes (auto-reload)
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  pattern = '*.log',
  callback = function()
    apply_baleia_colors()
  end,
})

-- Check for file changes periodically
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  pattern = '*.log',
  callback = function()
    vim.cmd('checktime')
  end,
})
