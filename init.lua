--[[


=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:


  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Use a dedicated virtualenv for Neovim's Python provider (keeps it separate from project envs/LSP)
vim.g.python3_host_prog = vim.fn.expand('~/.venvs/nvim/bin/python')
-- Set to true if you have a Nerd Font installed and selected in the terminal
-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true
-- Capture the directory Neovim was started in (used for statusline display)
vim.g.startup_cwd = vim.fn.getcwd(-1, -1)

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`
-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

vim.opt.mouse = 'a'
-- GUI font (ignored in terminal). Requires JetBrainsMono Nerd Font installed on the system.
vim.opt.guifont = 'JetBrainsMono Nerd Font:h12'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false
vim.opt.title = false
-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 1000

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.g.skip_ts_context_commentstring_module = true
-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Treesitter-powered folding with folds open by default
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>rr', '<cmd>edit<CR>', { desc = 'Reload file' })
vim.keymap.set('n', '<leader>lg', function()
  vim.cmd 'tabnew | term lazygit'
  vim.cmd 'startinsert'
end, { desc = 'Open Lazygit (tab terminal)' })
-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
-- Set leader key (if not already set)
-- Resize buffers using leader key
-- Map <leader>lt to :Leet test
vim.keymap.set('n', '<leader>ls', ':Leet submit<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lt', ':Leet test<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lr', ':Leet reset<CR>', { noremap = true, silent = true })

-- Replace with your actual connection string
local db_url = 'postgresql://myuser:password@localhost:5432/testdb'

-- Run whole SQL file
vim.keymap.set('n', '<leader>mm', ':%DB ' .. db_url .. '<CR>', {
  noremap = true,
  silent = true,
  desc = 'Run whole SQL file',
})

-- Run just the current visual selection
vim.keymap.set('v', '<leader>m', ':DB ' .. db_url .. '<CR>', {
  noremap = true,
  silent = true,
  desc = 'Run SQL selection',
})

-- Run just the current line
vim.keymap.set('n', '<leader>ml', ':.DB ' .. db_url .. '<CR>', {
  noremap = true,
  silent = true,
  desc = 'Run SQL line',
})
-- vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })
-- Somewhere else in your config (e.g. when sending a prompt), store it manually:
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

local function normalized_buf_path()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then
    return ''
  end
  if name:match '^oil://' then
    name = name:gsub('^oil://', 'file://')
    name = vim.uri_to_fname(name)
  end
  local path = vim.fs.normalize(name)
  local home = vim.loop.os_homedir()
  if home and path:sub(1, #home + 1) == home .. '/' then
    path = path:sub(#home + 2) -- strip "/home/user/"
  end
  return path
end

vim.keymap.set('n', '<leader>yd', function()
  local path = normalized_buf_path()
  if path == '' then
    return
  end
  vim.fn.setreg('+', vim.fn.fnamemodify(path, ':h'))
end, { desc = 'Yank file’s directory to clipboard' })
vim.keymap.set('n', '<leader>yf', function()
  local path = normalized_buf_path()
  if path == '' then
    return
  end
  local filename = vim.fn.fnamemodify(path, ':t')
  if filename == '' then
    return
  end
  vim.fn.setreg('+', filename)
  print('Copied filename: ' .. filename)
end, { desc = 'Yank filename to clipboard' })
vim.keymap.set('n', '<leader>jc', function()
  vim.cmd 'split | terminal curl -s https://jsonplaceholder.typicode.com/posts/1'
end, { desc = 'Fetch JSON Placeholder Post' })
vim.keymap.set('n', '<leader>yp', function()
  local path = normalized_buf_path()
  if path == '' then
    return
  end
  vim.fn.setreg('+', path)
  print('Copied full path: ' .. path)
end, { desc = 'Yank file’s directory + name' })

-- Quick popup showing the current file path; auto-closes after 2s or with 'q'
local function show_file_path_popup()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then
    name = '[No Name]'
  elseif name:match '^oil://' then
    name = name:gsub('^oil://', 'file://')
    name = vim.uri_to_fname(name)
  end
  local path = vim.fs.normalize(name)
  local home = vim.loop.os_homedir()
  if home and path:sub(1, #home + 1) == home .. '/' then
    path = path:sub(#home + 2) -- strip "/home/user/"
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local display_width = vim.fn.strdisplaywidth(path)
  local max_width = math.max(10, vim.o.columns - 4)
  local width = math.min(max_width, math.max(10, display_width + 2))
  local opts = {
    style = 'minimal',
    relative = 'editor',
    width = width,
    height = 1,
    row = 2,
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    border = 'rounded',
  }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { path })
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  local win = vim.api.nvim_open_win(buf, false, opts)
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, silent = true, nowait = true })
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, 2500)
end

vim.api.nvim_create_user_command('ShowFilePath', show_file_path_popup, { desc = 'Popup current file path' })
vim.keymap.set('n', '<leader>fp', show_file_path_popup, { desc = 'Show current file path popup' })
-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'oil',
  callback = function()
    vim.bo.fileformat = 'unix'
  end,
})

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
--
--
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'csv', 'tsv' },
  callback = function()
    vim.opt_local.wrap = false -- No line wrap
    vim.opt_local.linebreak = false -- No smart breaking
    vim.opt_local.breakindent = false -- No indent carryover
  end,
})
-- NOTE: Here is where you install your plugins.
require('lazy').setup({

  -- Plain-English TS errors
  {
    'dmmulroy/ts-error-translator.nvim',
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    config = function()
      require('ts-error-translator').setup()
    end,
  },

  -- A beautiful diagnostics panel (list of errors, quick jump, etc.)
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

  -- Show multi-line diagnostics above the code (great for long TS messages)
  {
    'maan2003/lsp_lines.nvim',
    event = 'VeryLazy',
    config = function()
      require('lsp_lines').setup()
      -- default to inline text; toggle to lsp_lines with <leader>tl
      vim.diagnostic.config { virtual_text = { prefix = '●' } }
    end,
  },

  -- Beautiful startup dashboard ("loading screen")
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- Don't show the dashboard if Neovim was started with files or stdin.
      if vim.fn.argc() > 0 then
        return
      end
      if vim.fn.line2byte('$') ~= -1 then
        return
      end

      local alpha = require 'alpha'
      local dashboard = require 'alpha.themes.dashboard'

      dashboard.section.header.val = {
        '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
        '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
        '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
        '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
        '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
        '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
      }

      dashboard.section.buttons.val = {
        dashboard.button('f', '  Find file', '<cmd>Telescope find_files<CR>'),
        dashboard.button('g', '  Live grep', '<cmd>Telescope live_grep<CR>'),
        dashboard.button('r', '  Recent files', '<cmd>Telescope oldfiles<CR>'),
        dashboard.button('n', '  New file', '<cmd>ene | startinsert<CR>'),
        dashboard.button('c', '  Edit config', '<cmd>edit ' .. vim.fn.stdpath 'config' .. '/init.lua<CR>'),
        dashboard.button('l', '󰒲  Lazy', '<cmd>Lazy<CR>'),
        dashboard.button('q', '󰅚  Quit', '<cmd>qa<CR>'),
      }

      dashboard.section.footer.val = function()
        local ok, lazy = pcall(require, 'lazy')
        if not ok then
          return ''
        end
        local stats = lazy.stats()
        local ms = math.floor((stats.startuptime or 0) * 100 + 0.5) / 100
        return ('󱐋 Loaded %d/%d plugins in %sms'):format(stats.loaded or 0, stats.count or 0, ms)
      end

      dashboard.section.header.opts.hl = 'Type'
      dashboard.section.buttons.opts.hl = 'Keyword'
      dashboard.section.footer.opts.hl = 'Comment'
      dashboard.opts.opts.noautocmd = true

      alpha.setup(dashboard.opts)

      local laststatus = vim.opt.laststatus:get()
      local showtabline = vim.opt.showtabline:get()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'alpha',
        callback = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.cursorline = false
          vim.opt_local.signcolumn = 'no'
          vim.opt.laststatus = 0
          vim.opt.showtabline = 0

          vim.api.nvim_create_autocmd('BufUnload', {
            buffer = 0,
            once = true,
            callback = function()
              vim.opt.laststatus = laststatus
              vim.opt.showtabline = showtabline
            end,
          })
        end,
      })
    end,
  },

  -- Nice statusline (looks great in interviews)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      local function startup_root_name()
        local root = vim.g.startup_cwd or vim.loop.cwd()
        return vim.fn.fnamemodify(root, ':t')
      end

      local function startup_root_path()
        local root = vim.g.startup_cwd or vim.loop.cwd()
        return vim.fn.fnamemodify(root, ':~')
      end

      local function path_from_startup()
        local path = normalized_buf_path and normalized_buf_path() or ''
        if path == '' then
          local root = vim.g.startup_cwd or vim.loop.cwd()
          return vim.fn.fnamemodify(root, ':t')
        end
        path = vim.fs.normalize(path)
        if vim.fn.isdirectory(path) == 1 then
          return vim.fn.fnamemodify(path, ':t') .. '/'
        end
        local fname = vim.fn.fnamemodify(path, ':t')
        local parent = vim.fn.fnamemodify(path, ':h:t')
        if parent ~= '' and parent ~= '.' then
          return parent .. '/' .. fname
        end
        return fname
      end

      return {
        options = {
          theme = 'auto', -- follow current colorscheme (Catppuccin)
          icons_enabled = vim.g.have_nerd_font, -- set to true if you install a Nerd Font
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { path_from_startup },
          lualine_x = { startup_root_name, 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      }
    end,
  },

  {
    'kdheepak/lazygit.nvim',
    cmd = 'LazyGit',
    keys = {
      { '<leader>lg', '<cmd>LazyGit<CR>', desc = 'Open Lazygit' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
  {
    'cameron-wags/rainbow_csv.nvim',
    config = true,
    ft = {
      'csv',
      'tsv',
      'csv_pipe',
      'csv_semicolon',
    },
    cmd = {
      'RainbowDelim',
      'Select',
      'Update',
      'RBQL',
    },
  },
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  {
    'tpope/vim-obsession', -- Session management plugin
    lazy = false, -- Load the plugin on startup
  },
  {
    'greggh/claude-code.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim', -- Required for git operations
    },
    config = function()
      require('claude-code').setup()
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Git blame' }, -- Lazy load for Git commands
    keys = {
      { '<leader>gb', ':Git blame<CR>', desc = 'Git Blame' },
    },
  },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      skip_confirm_for_simple_edits = true,
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },
    },
    -- Optional dependencies
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    keys = {
      { '<leader>o', ':Oil<CR>', desc = 'Open Oil File Explorer' }, -- Key mapping

      { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' }, -- Key mapping
    },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' }, -- Lazy load commands
    keys = {
      { '<leader>dv', ':DiffviewOpen<CR>', desc = 'Open Diffview' },
      { '<leader>dc', ':DiffviewClose<CR>', desc = 'Close Diffview' },
      { '<leader>df', ':DiffviewToggleFiles<CR>', desc = 'Toggle Diffview Files' },
      { '<leader>dq', ':DiffviewFocusFiles<CR>', desc = 'Focus Diffview Files' },
      { '<leader>dp', ':DiffviewOpen HEAD^<CR>', desc = 'Diff Previous Commit' },
      { '<leader>dv', ':DiffviewOpen<CR>', desc = 'Open Diffview (Working Directory Changes)' },
      { '<leader>db', ':DiffviewOpen origin/development...HEAD<CR>', desc = 'Diff Branch vs development' }, -- Diff full branch
    },
    config = function()
      require('diffview').setup {
        enhanced_diff_hl = true, -- Enable better diff highlighting
        use_icons = true, -- Use icons if available
      }
    end,
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter.configs').setup {
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
      }
    end,
  },
  {
    'ruifm/gitlinker.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('gitlinker').setup {
        opts = {
          add_current_line = true, -- Include the current line in the link
          action_callback = function(url)
            vim.fn.setreg('+', url) -- Copy the URL to the system clipboard (register '+')
            print('Copied URL to clipboard: ' .. url) -- Notify the user
          end,
          print_url = true, -- Print the URL in the terminal as well
        },
      }

      -- Keybinding to copy URL for the current file/line
      vim.keymap.set(
        'n', -- Normal mode
        '<leader>gl', -- Keybinding: <leader>gl
        function()
          require('gitlinker').get_buf_range_url 'n'
        end,
        { noremap = true, silent = true, desc = 'GitLinker: Copy repo link for current file/line' }
      )
    end,
  },
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('octo').setup()
    end,
  },
  {
    'numToStr/Comment.nvim',
    config = function()
      local ts_pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
      require('Comment').setup {
        pre_hook = function(ctx)
          local ft = vim.api.nvim_get_option_value('filetype', { buf = ctx.bufnr })
          if ft == 'liquid' then
            return '{% comment %}\n%s\n{% endcomment %}'
          end
          return ts_pre_hook(ctx)
        end,
      }
    end,
  },
  {
    'kawre/leetcode.nvim',
    build = function()
      local ok, ts_install = pcall(vim.cmd, 'TSInstall html')
      if not ok then
        print 'Failed to install Treesitter parser for HTML'
      end
    end,
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      lang = 'python3', -- Change to your preferred language
      use_treesitter = true,
    },
    config = function(_, opts)
      require('leetcode').setup(opts)
    end,
  },
  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --

  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'rest-nvim/rest.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-treesitter/nvim-treesitter',
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          for _, lang in ipairs { 'http', 'graphql' } do
            if not vim.tbl_contains(opts.ensure_installed, lang) then
              table.insert(opts.ensure_installed, lang)
            end
          end
        end,
      },
    },
    ft = { 'http' },
    opts = {
      request = { skip_ssl_verification = false },
      response = { hooks = { decode_url = true, format = true } },
      env = { enable = true, pattern = '.*%.env.*' },
      highlight = { enable = true, timeout = 150 },
    },
    config = function(_, opts)
      require('rest-nvim').setup(opts)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'http',
        callback = function(event)
          vim.b[event.buf]._rest_nvim_count = vim.b[event.buf]._rest_nvim_count or 1
          vim.keymap.set('n', 'rr', '<cmd>Rest run<cr>', {
            buffer = event.buf,
            desc = 'REST Run request',
          })
        end,
        group = vim.api.nvim_create_augroup('rest_nvim_buffer_defaults', { clear = true }),
      })
    end,
    keys = function()
      return {
        { '<leader>rp', '<cmd>Rest curl yank<cr>', desc = 'REST Copy cURL command' },
        { '<leader>rl', '<cmd>Rest last<cr>', desc = 'REST Re-run last request' },
      }
    end,
  },
  {
    'jparise/vim-graphql',
    ft = { 'graphql', 'gql', 'graphqls' },
  },
  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    version = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          -- mappings = {
          --   i = { ['<c-enter>'] = 'to_fuzzy_refine' },
          -- },
          --
          file_ignore_patterns = { 'git', 'node_modules' }, -- Keep ignoring unnecessary files
          hidden = true, -- Show hidden files
        },
        pickers = {
          find_files = {

            hidden = true, -- Ensure find_files includes hidden files
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- make colors pop
      vim.opt.termguicolors = true

      -- pretty borders for LSP hovers/signatures/diagnostic floats
      local _border = 'rounded'
      local orig = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or _border
        return orig(contents, syntax, opts, ...)
      end

      -- tuned diagnostics
      vim.diagnostic.config {
        severity_sort = true,
        update_in_insert = false,
        underline = true,
        signs = true,
        virtual_text = { prefix = '●', spacing = 1, source = 'if_many' },
        float = { border = 'rounded', source = 'if_many', focusable = false },
      }

      -- Only show diagnostic hover in NORMAL mode + toggleable
      local diag_hover_grp = vim.api.nvim_create_augroup('diag_hover_float', { clear = true })
      local diag_hover_enabled = true

      local function enable_diag_hover()
        vim.api.nvim_create_autocmd('CursorHold', { -- no CursorHoldI
          group = diag_hover_grp,
          callback = function()
            -- show only in normal-mode family (n, no, niI, etc.), and not in terminals
            local mode = vim.api.nvim_get_mode().mode
            if mode:sub(1, 1) ~= 'n' or vim.bo.buftype == 'terminal' then
              return
            end
            vim.diagnostic.open_float(nil, { border = 'rounded', focusable = false, scope = 'cursor' })
          end,
        })
        diag_hover_enabled = true
      end

      local function disable_diag_hover()
        vim.api.nvim_clear_autocmds { group = diag_hover_grp }
        diag_hover_enabled = false
      end

      -- start enabled
      enable_diag_hover()

      -- Toggle: <leader>tf
      vim.keymap.set('n', '<leader>tf', function()
        if diag_hover_enabled then
          disable_diag_hover()
          print 'Diagnostic hover: OFF'
        else
          enable_diag_hover()
          print 'Diagnostic hover: ON'
        end
      end, { desc = '[T]oggle diagnostic [F]loat' }) -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local function client_supports_method(client, method, bufnr)
            if not client then
              return false
            end
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            end
            return client.supports_method(method, { bufnr = bufnr })
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == 'ts_ls' then
            client.server_capabilities.documentFormattingProvider = false
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Change diagnostic symbols in the sign column (gutter)
      -- if vim.g.have_nerd_font then
      --   local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
      --   local diagnostic_signs = {}
      --   for type, icon in pairs(signs) do
      --     diagnostic_signs[vim.diagnostic.severity[type]] = icon
      --   end
      --   vim.diagnostic.config { signs = { text = diagnostic_signs } }
      -- end

      -- Put this somewhere after your LSP setup

      -- Toggle diagnostics (inline + signs)
      local diagnostics_active = true

      vim.keymap.set('n', '<leader>td', function()
        diagnostics_active = not diagnostics_active
        if diagnostics_active then
          vim.diagnostic.config {
            virtual_text = { prefix = '●' },
            signs = true,
            underline = true,
          }
          print 'Diagnostics: ON'
        else
          vim.diagnostic.config {
            virtual_text = false,
            signs = false,
            underline = false,
          }
          print 'Diagnostics: OFF'
        end
      end, { desc = '[T]oggle [D]iagnostics' })
      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())

      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      -- Enable the following language servers.
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --  Add any additional override configuration in the following tables. Available keys are documented in
      --  `:help vim.lsp.ClientConfig`.
      local servers = {
        -- clangd = {},
        -- gopls = {},
        omnisharp = {},
        pyright = {},
        -- Ruff handles linting & import fixes; pair with Pyright for type checking
        ruff = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs.
        ts_ls = {
          settings = {
            typescript = {
              preferences = {
                importModuleSpecifier = 'non-relative',
              },
            },
          },
        },
        denols = {
          root_markers = { 'deno.json', 'deno.jsonc' },
          workspace_required = true,
          settings = {
            deno = {
              enable = true,
              lint = true,
              unstable = true,
            },
          },
        },

        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed.
      -- To check the current status of installed tools and/or manually install other tools, run `:Mason`.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers)
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'csharpier',
        'isort',
        'black',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        automatic_enable = false,
      }

      for name, config in pairs(servers) do
        if next(config) ~= nil then
          local existing = vim.lsp.config[name]
          if existing and existing.on_attach and config.on_attach then
            local default_on_attach = existing.on_attach
            local user_on_attach = config.on_attach
            config.on_attach = function(client, bufnr)
              default_on_attach(client, bufnr)
              user_on_attach(client, bufnr)
            end
          end
          vim.lsp.config(name, config)
        end
      end

      for name in pairs(servers) do
        vim.lsp.enable(name)
      end
    end,
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
          ['j'] = cmp.mapping(function(fallback)
            if luasnip.choice_active() then
              luasnip.change_choice(1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['k'] = cmp.mapping(function(fallback)
            if luasnip.choice_active() then
              luasnip.change_choice(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },

  { -- Catppuccin colorscheme (Mocha)
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000, -- Load before other plugins
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha',
        integrations = {
          treesitter = true,
          which_key = true,
          lsp_trouble = true,
        },
      }
      vim.opt.background = 'dark'
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },
  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'query', 'vim', 'vimdoc', 'http', 'graphql' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      ignore_install = { 'csv' },
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  require 'kickstart.plugins.conform',
  require 'kickstart.plugins.mini',
  require 'kickstart.plugins.which-key',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
