-- Tokyonight-inspired custom colorscheme
local p = {
  bg = '#161827',
  bg_dark = '#12131d',
  bg_highlight = '#252b3b',
  fg = '#c0caf5',
  fg_dark = '#a9b1d6',
  fg_gutter = '#3b4261',
  comment = '#565f89',
  blue = '#7aa2f7',
  blue1 = '#2ac3de',
  cyan = '#7dcfff',
  magenta = '#bb9af7',
  purple = '#9d7cd8',
  orange = '#ff9e64',
  yellow = '#e0af68',
  green = '#9ece6a',
  teal = '#1abc9c',
  red = '#f7768e',
  dark3 = '#545c7e',
  terminal_black = '#414868',
}

vim.o.termguicolors = true
vim.o.background = 'dark'

vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') == 1 then
  vim.cmd('syntax reset')
end
vim.g.colors_name = 'mytokyonight'

local set = vim.api.nvim_set_hl

-- Base editor
set(0, 'Normal', { fg = p.fg, bg = p.bg })
set(0, 'NormalFloat', { fg = p.fg, bg = p.bg_dark })
set(0, 'FloatBorder', { fg = p.fg_gutter, bg = p.bg_dark })
set(0, 'FloatTitle', { fg = p.blue, bg = p.bg_dark, bold = true })
set(0, 'ColorColumn', { bg = p.bg_dark })
set(0, 'CursorLine', { bg = '#1f2335' })
set(0, 'CursorLineNr', { fg = p.yellow, bold = true })
set(0, 'LineNr', { fg = p.fg_gutter })
set(0, 'SignColumn', { bg = p.bg })
set(0, 'Folded', { fg = p.blue, bg = p.bg_dark })
set(0, 'FoldColumn', { fg = p.fg_gutter, bg = p.bg })
set(0, 'WinSeparator', { fg = p.bg_highlight, bg = p.bg })
set(0, 'VertSplit', { fg = p.bg_highlight })

-- Syntax
set(0, 'Comment', { fg = p.comment, italic = true })
set(0, 'Constant', { fg = p.orange })
set(0, 'String', { fg = p.green })
set(0, 'Character', { fg = p.orange })
set(0, 'Number', { fg = p.orange })
set(0, 'Boolean', { fg = p.orange })
set(0, 'Identifier', { fg = p.blue })
set(0, 'Function', { fg = p.blue, bold = true })
set(0, 'Statement', { fg = p.purple })
set(0, 'Conditional', { fg = p.purple })
set(0, 'Repeat', { fg = p.purple })
set(0, 'Operator', { fg = p.magenta })
set(0, 'Keyword', { fg = p.purple })
set(0, 'Type', { fg = p.yellow })
set(0, 'PreProc', { fg = p.magenta })
set(0, 'Special', { fg = p.blue1 })
set(0, 'Delimiter', { fg = p.fg_dark })

-- UI elements
set(0, 'NonText', { fg = p.bg_highlight })
set(0, 'Whitespace', { fg = p.fg_gutter })
set(0, 'Visual', { bg = '#2d3f76' })
set(0, 'Search', { fg = p.bg, bg = p.yellow, bold = true })
set(0, 'IncSearch', { fg = p.bg, bg = p.orange, bold = true })
set(0, 'MatchParen', { fg = p.orange, bg = p.bg_highlight, bold = true })
set(0, 'Pmenu', { fg = p.fg, bg = p.bg_dark })
set(0, 'PmenuSel', { fg = p.bg, bg = p.blue })
set(0, 'PmenuSbar', { bg = p.bg_dark })
set(0, 'PmenuThumb', { bg = p.fg_gutter })
set(0, 'StatusLine', { fg = p.fg, bg = p.bg_highlight })
set(0, 'StatusLineNC', { fg = p.fg_dark, bg = p.bg_dark })
set(0, 'TabLine', { fg = p.fg_dark, bg = p.bg_dark })
set(0, 'TabLineSel', { fg = p.yellow, bg = p.bg })
set(0, 'TabLineFill', { bg = p.bg_dark })

-- Diagnostics
set(0, 'DiagnosticError', { fg = p.red })
set(0, 'DiagnosticWarn', { fg = p.yellow })
set(0, 'DiagnosticInfo', { fg = p.cyan })
set(0, 'DiagnosticHint', { fg = p.teal })
set(0, 'DiagnosticUnderlineError', { undercurl = true, sp = p.red })
set(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = p.yellow })
set(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = p.cyan })
set(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = p.teal })

-- Diffs / git
set(0, 'DiffAdd', { fg = p.green, bg = '#1f2d3d' })
set(0, 'DiffChange', { fg = p.yellow, bg = '#24283b' })
set(0, 'DiffDelete', { fg = p.red, bg = '#2b1d26' })
set(0, 'DiffText', { fg = p.blue, bg = '#283457', bold = true })
set(0, 'GitSignsAdd', { fg = p.green })
set(0, 'GitSignsChange', { fg = p.yellow })
set(0, 'GitSignsDelete', { fg = p.red })

-- LSP references
set(0, 'LspReferenceText', { bg = p.bg_highlight })
set(0, 'LspReferenceRead', { bg = p.bg_highlight })
set(0, 'LspReferenceWrite', { bg = p.bg_highlight })
