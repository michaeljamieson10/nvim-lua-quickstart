local M = {}

local defaults = {
  collection_paths = {},
  picker = 'telescope',
  show_formatted_output = true,
  suppress_formatting_errors = false,
  env_file_root = nil,
  output = {
    buffer_name = 'Bruno Output',
    width = 0.50,
    height = 0.60,
    mode = 'split',
    border = 'rounded',
    title = 'Bruno Output',
  },
  cli = {
    cmd = 'bru',
    extra_args = {},
  },
}

local function normalize_collection_paths(collection_paths)
  local normalized = {}

  for _, entry in ipairs(collection_paths or {}) do
    if type(entry) == 'string' and entry ~= '' then
      table.insert(normalized, { path = vim.fs.normalize(vim.fn.expand(entry)) })
    elseif type(entry) == 'table' and type(entry.path) == 'string' and entry.path ~= '' then
      table.insert(normalized, {
        name = entry.name,
        path = vim.fs.normalize(vim.fn.expand(entry.path)),
      })
    end
  end

  return normalized
end

function M.apply(user_opts)
  local opts = vim.tbl_deep_extend('force', vim.deepcopy(defaults), user_opts or {})
  opts.collection_paths = normalize_collection_paths(opts.collection_paths)
  return opts
end

return M
