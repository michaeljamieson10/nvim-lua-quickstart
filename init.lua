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

      vim.diagnostic.config { virtual_text = { prefix = '●' } }
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'gruvbox',
        icons_enabled = vim.g.have_nerd_font,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
    },
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

  'tpope/vim-sleuth',
  {
    'tpope/vim-obsession',
    lazy = false,
  },
  {
    'greggh/claude-code.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
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
    cmd = { 'Git', 'G', 'Git blame' },
    keys = {
      { '<leader>gb', ':Git blame<CR>', desc = 'Git Blame' },
    },
  },
  {
    'stevearc/oil.nvim',

    opts = {
      skip_confirm_for_simple_edits = true,
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },
    },

    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    keys = {
      { '<leader>o', ':Oil<CR>', desc = 'Open Oil File Explorer' },

      { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' },
    },

    lazy = false,
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
    keys = {
      { '<leader>dv', ':DiffviewOpen<CR>', desc = 'Open Diffview' },
      { '<leader>dc', ':DiffviewClose<CR>', desc = 'Close Diffview' },
      { '<leader>df', ':DiffviewToggleFiles<CR>', desc = 'Toggle Diffview Files' },
      { '<leader>dq', ':DiffviewFocusFiles<CR>', desc = 'Focus Diffview Files' },
      { '<leader>dp', ':DiffviewOpen HEAD^<CR>', desc = 'Diff Previous Commit' },
      { '<leader>dv', ':DiffviewOpen<CR>', desc = 'Open Diffview (Working Directory Changes)' },
      { '<leader>db', ':DiffviewOpen origin/development...HEAD<CR>', desc = 'Diff Branch vs development' },
    },
    config = function()
      require('diffview').setup {
        enhanced_diff_hl = true,
        use_icons = true,
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
          add_current_line = true,
          action_callback = function(url)
            vim.fn.setreg('+', url)
            print('Copied URL to clipboard: ' .. url)
          end,
          print_url = true,
        },
      }

      vim.keymap.set(
        'n',
        '<leader>gl',
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
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
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
      lang = 'python3',
      use_treesitter = true,
    },
    config = function(_, opts)
      require('leetcode').setup(opts)
    end,
  },

  {
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
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',

        build = 'make',

        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local lspconfig = require 'lspconfig'

      local util = require 'lspconfig.util'

      lspconfig.ts_ls.setup {
        root_dir = lspconfig.util.root_pattern(
          'tsconfig.json',
          'package.json',
          '.git'
        ),
        on_attach = function(client, bufnr)

          client.server_capabilities.documentFormattingProvider = false

          local opts = { noremap = true, silent = true }
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        end,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        settings = {
          typescript = {
            preferences = {
              importModuleSpecifier = 'non-relative',
            },
          },
        },
      }
      lspconfig.denols.setup {
        root_dir = util.root_pattern 'deno.json',
        single_file_support = false,
        init_options = {
          lint = true,
          unstable = true,
        },
        on_attach = function(client, bufnr)
          print 'Deno LSP attached'
          local opts = { noremap = true, silent = true }
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        end,
      }

      require('telescope').setup {

        defaults = {

          file_ignore_patterns = { 'git', 'node_modules' },
          hidden = true,
        },
        pickers = {
          find_files = {

            hidden = true,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      vim.opt.termguicolors = true

      local _border = 'rounded'
      local orig = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or _border
        return orig(contents, syntax, opts, ...)
      end

      vim.diagnostic.config {
        severity_sort = true,
        update_in_insert = false,
        underline = true,
        signs = true,
        virtual_text = { prefix = '●', spacing = 1, source = 'if_many' },
        float = { border = 'rounded', source = 'if_many', focusable = false },
      }

      local diag_hover_grp = vim.api.nvim_create_augroup('diag_hover_float', { clear = true })
      local diag_hover_enabled = true

      local function enable_diag_hover()
        vim.api.nvim_create_autocmd('CursorHold', {
          group = diag_hover_grp,
          callback = function()

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

      enable_diag_hover()

      vim.keymap.set('n', '<leader>tf', function()
        if diag_hover_enabled then
          disable_diag_hover()
          print 'Diagnostic hover: OFF'
        else
          enable_diag_hover()
          print 'Diagnostic hover: ON'
        end
      end, { desc = '[T]oggle diagnostic [F]loat' })
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

      vim.keymap.set('n', '<leader>/', function()

        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  {

    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {

        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {

    'neovim/nvim-lspconfig',
    dependencies = {

      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      { 'j-hui/fidget.nvim', opts = {} },

      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)

          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

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

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {

        pyright = {},

        ts_ls = {},

        lua_ls = {

          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },

            },
          },
        },
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}

            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {

      {
        'L3MON4D3/LuaSnip',
        build = (function()

          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {

        },
      },
      'saadparwaiz1/cmp_luasnip',

      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()

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

        mapping = cmp.mapping.preset.insert {

          ['<C-n>'] = cmp.mapping.select_next_item(),

          ['<C-p>'] = cmp.mapping.select_prev_item(),

          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          ['<C-y>'] = cmp.mapping.confirm { select = true },

          ['<C-Space>'] = cmp.mapping.complete {},

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

        },
        sources = {
          {
            name = 'lazydev',

            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },

  {

    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()

    end,
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()

      vim.g.gruvbox_contrast_dark = 'hard'
      vim.opt.background = 'dark'
      vim.cmd.colorscheme 'gruvbox'
    end,
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',

    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },

      auto_install = true,
      ignore_install = { 'csv' },
      highlight = {
        enable = true,

        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },

  },

  require 'kickstart.plugins.conform',
  require 'kickstart.plugins.mini',
  require 'kickstart.plugins.which-key',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns',

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

