local M = {}

local utils_path = vim.fn.expand '~/Code/translator/src/utils.ts'
local liquid_utils_path = vim.fn.expand '~/Code/translator/src/liquid-utils.ts'

local extra_filters = {
  'compact',
  'concat',
  'default',
  'pop',
  'push',
  'sort_natural',
}

local cache = {
  items = nil,
  stats = {},
}

local function file_mtime(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then
    return nil
  end
  return stat.mtime.sec .. ':' .. stat.mtime.nsec
end

local function read_lines(path)
  if vim.fn.filereadable(path) ~= 1 then
    return {}
  end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return {}
  end
  return lines
end

local function add_name(target, name, detail, kind)
  if name and name ~= '' then
    target[name] = { detail = detail, kind = kind }
  end
end

local function parse_utils_exports(target)
  for _, line in ipairs(read_lines(utils_path)) do
    local name = line:match('^%s*export%s+async%s+function%s+([%w_]+)')
    if not name then
      name = line:match('^%s*export%s+function%s+([%w_]+)')
    end
    if not name then
      name = line:match('^%s*export%s+const%s+([%w_]+)')
    end
    if not name then
      name = line:match('^%s*export%s+class%s+([%w_]+)')
    end
    if not name then
      name = line:match('^%s*export%s+enum%s+([%w_]+)')
    end
    if not name then
      name = line:match('^%s*export%s+type%s+([%w_]+)')
    end
    if not name then
      name = line:match('^%s*export%s+interface%s+([%w_]+)')
    end
    if name then
      add_name(target, name, 'translator utils export', 'function')
    end
  end
end

local function parse_liquid_utils(target)
  for _, line in ipairs(read_lines(liquid_utils_path)) do
    local filter = line:match("registerFilter%(%s*'([^']+)'")
    if filter then
      add_name(target, filter, 'liquid filter', 'function')
    end
    local tag = line:match("registerTag%(%s*'([^']+)'")
    if tag then
      add_name(target, tag, 'liquid tag', 'keyword')
    end
  end
  for _, name in ipairs(extra_filters) do
    add_name(target, name, 'liquid filter', 'function')
  end
end

local function build_items()
  local names = {}
  parse_utils_exports(names)
  parse_liquid_utils(names)

  local items = {}
  local cmp_ok, cmp = pcall(require, 'cmp')
  local kinds = cmp_ok and cmp.lsp.CompletionItemKind or {}

  for name, meta in pairs(names) do
    local kind = meta.kind == 'keyword' and kinds.Keyword or kinds.Function
    table.insert(items, { label = name, kind = kind, detail = meta.detail })
  end

  table.sort(items, function(a, b)
    return a.label < b.label
  end)

  return items
end

local function get_items()
  local utils_mtime = file_mtime(utils_path)
  local liquid_mtime = file_mtime(liquid_utils_path)

  if
    cache.items
    and cache.stats.utils == utils_mtime
    and cache.stats.liquid == liquid_mtime
  then
    return cache.items
  end

  cache.items = build_items()
  cache.stats.utils = utils_mtime
  cache.stats.liquid = liquid_mtime
  return cache.items
end

local source = {}

function source.complete(_, _, callback)
  callback({ items = get_items(), isIncomplete = false })
end

function source.is_available()
  return vim.bo.filetype == 'liquid'
end

function M.setup()
  if M._registered then
    return
  end

  local ok, cmp = pcall(require, 'cmp')
  if not ok then
    return
  end

  cmp.register_source('liquid_utils', source)
  cmp.setup.filetype('liquid', {
    sources = cmp.config.sources({
      { name = 'liquid_utils' },
      { name = 'luasnip' },
      { name = 'path' },
    }),
  })

  M._registered = true
end

return M
