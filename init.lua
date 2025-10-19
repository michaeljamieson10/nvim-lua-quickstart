vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = false

vim.opt.number = true

vim.opt.relativenumber = true

vim.opt.mouse = 'a'

vim.opt.showmode = false

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true

vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = 'yes'

vim.opt.updatetime = 1000

vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.g.skip_ts_context_commentstring_module = true

vim.opt.inccommand = 'split'

vim.opt.termguicolors = true

vim.opt.cursorline = true

vim.opt.scrolloff = 10

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>lg', ':LazyGit<CR>', { desc = 'Open Lazygit' })

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<leader>k', ':resize +15<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>j', ':resize -15<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>h', ':vertical resize -15<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>l', ':vertical resize +15<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>ls', ':Leet submit<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lt', ':Leet test<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lr', ':Leet reset<CR>', { noremap = true, silent = true })

local db_url = 'postgresql://myuser:password@localhost:5432/testdb'

vim.keymap.set('n', '<leader>mm', ':%DB ' .. db_url .. '<CR>', {
  noremap = true,
  silent = true,
  desc = 'Run whole SQL file',
})

vim.keymap.set('v', '<leader>m', ':DB ' .. db_url .. '<CR>', {
  noremap = true,
  silent = true,
  desc = 'Run SQL selection',
})

vim.keymap.set('n', '<leader>ml', ':.DB ' .. db_url .. '<CR>', {
  noremap = true,
  silent = true,
  desc = 'Run SQL line',
})

vim.keymap.set('n', '<leader>cx', function()
  local path = vim.fn.expand '%:p'

  vim.cmd 'ClaudeCode'

  vim.defer_fn(function()
    local message = 'Custom target file:\n\n' .. path .. '\n'
    vim.api.nvim_chan_send(vim.b.terminal_job_id, message)
  end, 100)
end, { desc = 'Send file path to Claude' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>yd', function()
  vim.fn.setreg('+', vim.fn.expand '%:p:h')
end, { desc = 'Yank file’s directory to clipboard' })
vim.keymap.set('n', '<leader>jc', function()
  vim.cmd 'split | terminal curl -s https://jsonplaceholder.typicode.com/posts/1'
end, { desc = 'Fetch JSON Placeholder Post' })
vim.keymap.set('n', '<leader>yp', function()
  local dir = vim.fn.expand '%:p:h'
  local file = vim.fn.expand '%:t'
  local path = dir .. '/' .. file
  vim.fn.setreg('+', path)
  print('Copied full path: ' .. path)
end, { desc = 'Yank file’s directory + name' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'oil',
  callback = function()
    vim.bo.fileformat = 'unix'
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'csv', 'tsv' },
  callback = function()
    vim.opt_local.wrap = false
    vim.opt_local.linebreak = false
    vim.opt_local.breakindent = false
  end,
})

require('lazy').setup({
  { import = 'custom.plugins' },
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.conform',
  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.mini',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns',
  require 'kickstart.plugins.which-key',

  { import = 'custom.plugins' },

}, {
  ui = {

    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
