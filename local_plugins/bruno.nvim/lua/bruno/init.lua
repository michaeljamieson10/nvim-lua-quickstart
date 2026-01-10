local M = {}

local Path = require 'plenary.path'

local config = require 'bruno.config'
local cli = require 'bruno.cli'
local formatter = require 'bruno.format'
local pickers = require 'bruno.pickers'
local sidebar = require 'bruno.sidebar'
local state = require 'bruno.state'
local scandir = require 'plenary.scandir'

local header_ns = vim.api.nvim_create_namespace 'bruno.nvim.header'

local function state_path()
  return vim.fn.stdpath('state') .. '/bruno.nvim.json'
end

local function load_persisted_state()
  local path = state_path()
  if vim.fn.filereadable(path) ~= 1 then
    return
  end
  local contents = table.concat(vim.fn.readfile(path), '\n')
  local ok, decoded = pcall(vim.json.decode, contents)
  if not ok or type(decoded) ~= 'table' then
    return
  end
  if type(decoded.current_env) == 'string' then
    state.current_env = decoded.current_env
  end
  if type(decoded.current_env_file) == 'string' then
    state.current_env_file = decoded.current_env_file
  end
  if type(decoded.last_bru_file) == 'string' and decoded.last_bru_file ~= '' then
    state.last_bru_file = decoded.last_bru_file
    vim.g.last_bru_file = decoded.last_bru_file
  end
end

local function persist_state()
  local payload = {
    current_env = state.current_env,
    current_env_file = state.current_env_file,
    last_bru_file = state.last_bru_file,
  }
  local ok, encoded = pcall(vim.json.encode, payload)
  if not ok then
    return
  end
  vim.fn.writefile(vim.split(encoded, '\n', { plain = true }), state_path())
end

local function setup_highlights()
  vim.api.nvim_set_hl(0, 'BrunoStatusOk', { link = 'DiagnosticOk' })
  vim.api.nvim_set_hl(0, 'BrunoStatusInfo', { link = 'DiagnosticInfo' })
  vim.api.nvim_set_hl(0, 'BrunoStatusWarn', { link = 'DiagnosticWarn' })
  vim.api.nvim_set_hl(0, 'BrunoStatusError', { link = 'DiagnosticError' })
  vim.api.nvim_set_hl(0, 'BrunoStatusOther', { link = 'Normal' })
  vim.api.nvim_set_hl(0, 'BrunoHeaderTitle', { link = 'Title' })
  vim.api.nvim_set_hl(0, 'BrunoHeaderMeta', { link = 'Comment' })
  vim.api.nvim_set_hl(0, 'BrunoHeaderSection', { link = 'Title' })
  vim.api.nvim_set_hl(0, 'BrunoTabActive', { link = 'Title' })
  vim.api.nvim_set_hl(0, 'BrunoTabInactive', { link = 'Comment' })
end

local function status_hl_for_code(code)
  local n = tonumber(code)
  if not n then
    return 'BrunoStatusOther'
  end
  if n >= 200 and n < 300 then
    return 'BrunoStatusOk'
  end
  if n >= 300 and n < 400 then
    return 'BrunoStatusInfo'
  end
  if n >= 400 and n < 500 then
    return 'BrunoStatusWarn'
  end
  if n >= 500 and n < 600 then
    return 'BrunoStatusError'
  end
  return 'BrunoStatusOther'
end

local function extract_http_status(raw_output)
  local ok, data = pcall(vim.json.decode, raw_output)
  if not ok or not data or not data.results or #data.results == 0 then
    if not ok or not data then
      return nil
    end
    if type(data) == 'table' and data[1] and type(data[1]) == 'table' then
      data = data[1]
    else
      return nil
    end
  end

  local result = data.results and data.results[1] or {}
  local response = result.response or {}
  if response.status == nil then
    return nil
  end

  return {
    code = response.status,
    text = response.statusText,
  }
end

local function current_env_label()
  if state.current_env_file and state.current_env_file ~= '' then
    return vim.fn.fnamemodify(state.current_env_file, ':t')
  end
  if state.current_env and state.current_env ~= '' then
    return state.current_env
  end
  return nil
end

local function apply_header(bufnr, tab_line, tab_positions, status, active_tab)
  vim.api.nvim_buf_clear_namespace(bufnr, header_ns, 0, 2)

  for _, pos in ipairs(tab_positions or {}) do
    local hl = (pos.name == active_tab) and 'BrunoTabActive' or 'BrunoTabInactive'
    vim.api.nvim_buf_add_highlight(bufnr, header_ns, hl, 0, pos.start_col, pos.end_col)
  end

  if status and status.code ~= nil then
    local code_str = tostring(status.code)
    local s, e = tab_line:find(code_str, 1, true)
    if s then
      vim.api.nvim_buf_add_highlight(bufnr, header_ns, status_hl_for_code(status.code), 0, s - 1, e)
    end
  end
end

local function apply_section_highlights(bufnr, lines, start_line)
  for i, line in ipairs(lines) do
    if line:match('^//%s+') then
      vim.api.nvim_buf_add_highlight(bufnr, header_ns, 'BrunoHeaderSection', start_line + i - 1, 0, -1)
    end
  end
end

local function render_sections(bufnr, status, sections, view_index)
  local view = sections.all
  local view_name = 'all'
  if view_index and sections.list and sections.list[view_index] then
    view_name = sections.list[view_index]
    view = sections[view_name] or sections.all
  end

  local tabs = { 'Response', 'Headers', 'Meta', 'All' }
  local tab_line = table.concat(tabs, ' | ')
  local tab_positions = {}
  local col = 0
  for i, name in ipairs(tabs) do
    local start_col = col
    local end_col = start_col + #name
    tab_positions[i] = { name = name, start_col = start_col, end_col = end_col }
    col = end_col + 3
  end

  local status_label = status and status.code ~= nil and tostring(status.code) or 'none'
  tab_line = tab_line .. ('   (%s)'):format(status_label)

  -- Trim leading empty lines from view
  local trimmed_view = {}
  local found_content = false
  for _, line in ipairs(view or {}) do
    if not found_content and line ~= '' then
      found_content = true
    end
    if found_content then
      table.insert(trimmed_view, line)
    end
  end

  local out = { tab_line, '' }
  vim.list_extend(out, trimmed_view)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out)
  apply_header(bufnr, tab_line, tab_positions, status, view_name:gsub('^%l', string.upper))
  apply_section_highlights(bufnr, out, 0)
end

local function with_header(bufnr, status, lines)
  local env = current_env_label() or 'none'
  local header
  if status and status.code ~= nil then
    header = ('response: %s'):format(tostring(status.code))
  else
    header = 'response: none'
  end

  -- Trim leading empty lines from lines
  local trimmed_lines = {}
  local found_content = false
  for _, line in ipairs(lines or {}) do
    if not found_content and line ~= '' then
      found_content = true
    end
    if found_content then
      table.insert(trimmed_lines, line)
    end
  end

  local out = { header, ('env: %s'):format(env), '' }
  vim.list_extend(out, trimmed_lines)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out)
  apply_header(bufnr, header, status)
  apply_section_highlights(bufnr, out)
end

local function get_last_bru_file()
  return state.last_bru_file or vim.g.last_bru_file
end

local function set_last_bru_file(path)
  if not path or path == '' then
    return
  end
  state.last_bru_file = path
  vim.g.last_bru_file = path
  persist_state()
end

local function get_valid_collections(opts)
  return vim.tbl_filter(function(collection_info)
    return collection_info.path and Path:new(collection_info.path):exists()
  end, opts.collection_paths)
end

local function get_current_bru_file()
  local current_file = vim.fn.expand '%:p'
  if vim.fn.fnamemodify(current_file, ':e') == 'bru' then
    return current_file
  end

  local last_bru = get_last_bru_file()
  if last_bru and vim.fn.filereadable(last_bru) == 1 then
    return last_bru
  end

  vim.notify('Current file is not a .bru file and no valid last .bru file found', vim.log.levels.WARN, { title = 'bruno.nvim' })
  return nil
end

local function get_cached_bru_file()
  local last_bru = get_last_bru_file()
  if last_bru and vim.fn.filereadable(last_bru) == 1 then
    return last_bru
  end
  return nil
end

local function read_file_to_string(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end
  return table.concat(vim.fn.readfile(path), '\n')
end

local function write_string_to_file(path, contents)
  local lines = vim.split(contents or '', '\n', { plain = true })
  vim.fn.writefile(lines, path)
end

local function relative_path(path, root)
  if not path or not root then
    return path
  end
  local norm_root = vim.fs.normalize(root)
  local norm_path = vim.fs.normalize(path)
  if norm_path:sub(1, #norm_root + 1) == norm_root .. '/' then
    return norm_path:sub(#norm_root + 2)
  end
  return path
end

local function make_temp_collection(root_dir, request_basename, request_contents)
  local temp_root = vim.fn.tempname()
  vim.fn.mkdir(temp_root, 'p')

  local function copy_if_exists(src_name, dest_name)
    local src = root_dir .. '/' .. src_name
    if vim.fn.filereadable(src) ~= 1 then
      return
    end
    local contents = read_file_to_string(src)
    if contents then
      write_string_to_file(temp_root .. '/' .. (dest_name or src_name), contents)
    end
  end

  copy_if_exists('bruno.json')
  copy_if_exists('collection.bru')

  local temp_request = temp_root .. '/' .. request_basename
  write_string_to_file(temp_request, request_contents)

  return temp_root, temp_request
end

local function override_request_auth(contents, auth_mode)
  if not auth_mode or auth_mode == '' then
    return contents
  end

  local lines = vim.split(contents or '', '\n', { plain = true })
  local in_post = false
  local post_start_indent = ''
  local updated = false

  for i, line in ipairs(lines) do
    if not in_post then
      local indent = line:match('^(%s*)post%s*{%s*$')
      if indent ~= nil then
        in_post = true
        post_start_indent = indent
      end
    else
      if line:match('^%s*auth:%s*%S+') then
        local indent = line:match('^(%s*)') or (post_start_indent .. '  ')
        lines[i] = indent .. 'auth: ' .. auth_mode
        updated = true
        break
      end

      if line:match('^%s*}%s*$') then
        local insert_at = i
        local indent = post_start_indent .. '  '
        table.insert(lines, insert_at, indent .. 'auth: ' .. auth_mode)
        updated = true
        break
      end
    end
  end

  if not updated then
    return contents
  end

  return table.concat(lines, '\n')
end

local function write_output(bufnr, opts, raw_output)
  state.last_raw_output = raw_output

  local status = extract_http_status(raw_output)
  if status and status.code ~= nil then
    vim.b[bufnr].bruno_http_status = status.code
    vim.b[bufnr].bruno_http_status_hl = status_hl_for_code(status.code)
    vim.b[bufnr].bruno_http_status_text = status.text
  else
    vim.b[bufnr].bruno_http_status = nil
    vim.b[bufnr].bruno_http_status_hl = nil
    vim.b[bufnr].bruno_http_status_text = nil
  end

  if opts.show_formatted_output then
    local ok, data = pcall(vim.json.decode, raw_output)
    if ok then
      if type(data) == 'table' and data[1] and type(data[1]) == 'table' then
        data = data[1]
      end

      local result = data.results and data.results[1] or nil
      if result then
        local response = result.response or {}
        local response_body = nil
        for _, value in ipairs { response.data, response.body, response.text, response.raw, response.content } do
          if value ~= nil and value ~= vim.NIL then
            response_body = value
            break
          end
        end
        local sections = {
          list = { 'response', 'headers', 'meta', 'all' },
          response = formatter.pretty_json_lines(response_body),
          headers = formatter.pretty_json_lines(response.headers),
          meta = formatter.pretty_json_lines {
            status = response.status,
            statusText = response.statusText,
            responseTime = response.responseTime,
            url = response.url,
          },
        }
        sections.all = vim.split(raw_output, '\n')

        vim.api.nvim_set_option_value('filetype', 'jsonc', { buf = bufnr })
        vim.b[bufnr].bruno_sections = sections
        vim.b[bufnr].bruno_view_index = vim.b[bufnr].bruno_view_index or 1
        render_sections(bufnr, status, sections, vim.b[bufnr].bruno_view_index)
        return
      end
    end

    vim.api.nvim_set_option_value('filetype', 'json', { buf = bufnr })
    with_header(bufnr, status, vim.split(raw_output, '\n'))
    if not opts.suppress_formatting_errors then
      vim.notify('Failed to format output, falling back to raw output.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    end
    return
  end

  vim.api.nvim_set_option_value('filetype', 'json', { buf = bufnr })
  with_header(bufnr, status, vim.split(raw_output, '\n'))
end

function M.search()
  local opts = M.opts or config.apply {}
  local collections = get_valid_collections(opts)
  if #collections == 0 then
    vim.notify('No valid Bruno collections found (configure `collection_paths`).', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  local search_dirs = vim.tbl_map(function(collection)
    return collection.path
  end, collections)

  pickers.search(search_dirs, opts.picker, 'Bruno Files')
end

function M.toggle_output_format()
  local opts = M.opts
  opts.show_formatted_output = not opts.show_formatted_output

  if not state.last_raw_output then
    return
  end

  local bufnr = vim.fn.bufnr(opts.output.buffer_name)
  if bufnr == -1 then
    return
  end

  write_output(bufnr, opts, state.last_raw_output)
end

local function find_environments_dir()
  local search_dir = vim.fn.expand '%:p:h'
  local env_dir = vim.fn.finddir('environments', search_dir .. ';')

  local last_bru = get_cached_bru_file()
  if env_dir == '' and last_bru then
    search_dir = vim.fn.fnamemodify(last_bru, ':p:h')
    env_dir = vim.fn.finddir('environments', search_dir .. ';')
  end

  return env_dir
end

function M.set_env(env_name)
  if not env_name or env_name == '' then
    vim.notify('No environment name provided.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  state.current_env = env_name
  persist_state()
  vim.notify('Bruno environment set to: ' .. env_name, vim.log.levels.INFO, { title = 'bruno.nvim' })
end

function M.clear_env()
  state.current_env = nil
  persist_state()
  vim.notify('Bruno environment cleared.', vim.log.levels.INFO, { title = 'bruno.nvim' })
end

function M.set_env_file(path)
  if not path or path == '' then
    vim.notify('No env file path provided.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  local expanded = vim.fs.normalize(vim.fn.expand(path))
  if vim.fn.filereadable(expanded) ~= 1 then
    vim.notify('Env file is not readable: ' .. expanded, vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  local ext = vim.fn.fnamemodify(expanded, ':e')
  if ext ~= 'json' and ext ~= 'bru' then
    vim.notify('Env file must be a .json or .bru file.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  state.current_env_file = expanded
  persist_state()
  vim.notify('Bruno env file set: ' .. expanded, vim.log.levels.INFO, { title = 'bruno.nvim' })
end

function M.clear_env_file()
  state.current_env_file = nil
  persist_state()
  vim.notify('Bruno env file cleared.', vim.log.levels.INFO, { title = 'bruno.nvim' })
end

function M.env_file_from_buffer()
  local file = vim.fn.expand '%:p'
  if file == '' then
    vim.notify('No file associated with current buffer.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end
  return M.set_env_file(file)
end

function M.env_file_pick()
  local opts = M.opts
  local root = opts.env_file_root
  if not root or root == '' then
    vim.notify('No `env_file_root` configured for bruno.nvim.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  root = vim.fs.normalize(vim.fn.expand(root))
  if vim.fn.isdirectory(root) ~= 1 then
    vim.notify('Env file root is not a directory: ' .. root, vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  local files = scandir.scan_dir(root, { hidden = false, add_dirs = false, depth = 10 })
  files = vim.tbl_filter(function(path)
    local ext = vim.fn.fnamemodify(path, ':e')
    return ext == 'bru' or ext == 'json'
  end, files)

  if #files == 0 then
    vim.notify('No .bru or .json env files found under: ' .. root, vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  table.sort(files)

  pickers.pick_env(files, opts.picker, 'Bruno Env Files', function(path)
    M.set_env_file(path)
  end)
end

local function get_nested_value(obj, keypath)
  if type(keypath) ~= 'string' or keypath == '' then
    return nil
  end

  local cur = obj
  for part in keypath:gmatch('[^%.]+') do
    if type(cur) ~= 'table' then
      return nil
    end
    cur = cur[part]
  end

  return cur
end

local function extract_env_name_from_json(json_obj, keypath)
  if type(json_obj) ~= 'table' then
    return nil
  end

  local candidates = {}
  if keypath and keypath ~= '' then
    candidates = { keypath }
  else
    candidates = {
      'bruno.env',
      'bruno.environment',
      'environment',
      'env',
      'defaultEnvironment',
      'default_environment',
      'activeEnvironment',
      'active_environment',
      'name',
    }
  end

  for _, path in ipairs(candidates) do
    local val = get_nested_value(json_obj, path)
    if type(val) == 'string' and val ~= '' then
      return val
    end
    if type(val) == 'table' and type(val.name) == 'string' and val.name ~= '' then
      return val.name
    end
  end

  return nil
end

function M.env_from_file(opts)
  opts = opts or {}
  local keypath = opts.keypath

  local file = vim.fn.expand '%:p'
  if file == '' then
    vim.notify('No file associated with current buffer.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  local ext = vim.fn.fnamemodify(file, ':e')
  if ext == 'bru' then
    local env_name = vim.fn.fnamemodify(file, ':t:r')
    return M.set_env(env_name)
  end

  if ext ~= 'json' then
    vim.notify('Current file is not JSON (or .bru). Open a JSON file that contains an env name.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  local json_text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
  local ok, decoded = pcall(vim.json.decode, json_text)
  if not ok then
    vim.notify('Failed to parse JSON in current buffer.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  local env_name = extract_env_name_from_json(decoded, keypath)
  if not env_name then
    vim.notify(
      'No environment name found in JSON. Add one of: env, environment, defaultEnvironment, activeEnvironment, bruno.env (or pass a keypath).',
      vim.log.levels.WARN,
      { title = 'bruno.nvim' }
    )
    return
  end

  return M.set_env(env_name)
end

function M.env()
  local opts = M.opts
  local env_dir = find_environments_dir()
  if env_dir == '' then
    vim.notify(
      'Environments directory not found. Run :BrunoRun first, or open a .bru file inside a collection.',
      vim.log.levels.WARN,
      { title = 'bruno.nvim' }
    )
    return
  end

  local env_files = vim.fn.glob(env_dir .. '/*.bru', false, true)
  if #env_files == 0 then
    vim.notify('No .bru files found in the environments directory.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  local env_names = vim.tbl_map(function(file)
    return vim.fn.fnamemodify(file, ':t:r')
  end, env_files)

  pickers.pick_env(env_names, opts.picker, 'Bruno Environments', function(env_name)
    M.set_env(env_name)
  end)
end

local function resolve_output(opts, output_override)
  if not output_override then
    return opts.output
  end
  local base = vim.deepcopy(opts.output or {})
  return vim.tbl_deep_extend('force', base, output_override)
end

local function run_request(current_file, output_override)
  local opts = M.opts
  if not current_file then
    return
  end
  if vim.fn.filereadable(current_file) ~= 1 then
    vim.notify('Bruno request is not readable: ' .. current_file, vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  set_last_bru_file(current_file)

  local bruno_root = vim.fn.findfile('bruno.json', vim.fn.fnamemodify(current_file, ':p:h') .. ';')
  if bruno_root == '' then
    vim.notify('Bruno collection root not found (missing bruno.json).', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  if not state.current_env and not state.current_env_file then
    vim.notify('You must set an env (use <leader>be or :BrunoEnvFileSet / :BrunoEnv).', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  local root_dir = vim.fn.fnamemodify(bruno_root, ':p:h')
  local temp_file = vim.fn.tempname()

  local request_to_run = current_file
  local run_cwd = root_dir
  local temp_collection_root = nil

  -- If we need to override the request auth, run it from a temporary "collection"
  -- root to avoid touching the real collection on disk.
  if state.auth_mode and state.auth_mode ~= '' then
    local original = read_file_to_string(current_file)
    if original then
      local overridden = override_request_auth(original, state.auth_mode)
      if overridden ~= original then
        local basename = vim.fn.fnamemodify(current_file, ':t')
        local temp_root, temp_request = make_temp_collection(root_dir, basename, overridden)
        temp_collection_root = temp_root
        run_cwd = temp_root
        request_to_run = temp_request
      end
    end
  end

  local request_arg = relative_path(request_to_run, run_cwd)
  local args = { opts.cli.cmd, 'run', request_arg, '-o', temp_file }
  vim.list_extend(args, opts.cli.extra_args or {})
  if state.current_env then
    vim.list_extend(args, { '--env', state.current_env })
  end
  if state.current_env_file then
    vim.list_extend(args, { '--env-file', state.current_env_file })
  end

  local output = resolve_output(opts, output_override)
  local bufnr = sidebar.get_or_create(output)
  vim.api.nvim_set_option_value('filetype', 'text', { buf = bufnr })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'Running Bruno request...' })
  if not vim.b[bufnr].bruno_section_keys then
    vim.b[bufnr].bruno_section_keys = true
    vim.keymap.set('n', ']s', function()
      vim.fn.search('^//\\s\\+', 'W')
    end, { buffer = bufnr, desc = 'Next Bruno section' })
    vim.keymap.set('n', '[s', function()
      vim.fn.search('^//\\s\\+', 'bW')
    end, { buffer = bufnr, desc = 'Previous Bruno section' })
    vim.keymap.set('n', ']', function()
      local sections = vim.b[bufnr].bruno_sections
      if not sections or not sections.list then
        return
      end
      local max = #sections.list
      local idx = (vim.b[bufnr].bruno_view_index or max) + 1
      if idx > max then
        idx = 1
      end
      vim.b[bufnr].bruno_view_index = idx
      local status = {
        code = vim.b[bufnr].bruno_http_status,
        text = vim.b[bufnr].bruno_http_status_text,
      }
      render_sections(bufnr, status, sections, idx)
    end, { buffer = bufnr, desc = 'Bruno: Next view' })
    vim.keymap.set('n', '[', function()
      local sections = vim.b[bufnr].bruno_sections
      if not sections or not sections.list then
        return
      end
      local max = #sections.list
      local idx = (vim.b[bufnr].bruno_view_index or max) - 1
      if idx < 1 then
        idx = max
      end
      vim.b[bufnr].bruno_view_index = idx
      local status = {
        code = vim.b[bufnr].bruno_http_status,
        text = vim.b[bufnr].bruno_http_status_text,
      }
      render_sections(bufnr, status, sections, idx)
    end, { buffer = bufnr, desc = 'Bruno: Previous view' })
  end

  cli.run(args, { cwd = run_cwd }, function(exit_code, stdout, stderr)
    vim.schedule(function()
      local ok_exit = exit_code == 0 or exit_code == 1
      local output_file_contents = read_file_to_string(temp_file)

      if not ok_exit or not output_file_contents then
        local lines = { 'Bruno run failed with the following output:' }
        local combined = {}
        if stdout and stdout ~= '' then
          vim.list_extend(combined, vim.split(stdout, '\n'))
        end
        if stderr and stderr ~= '' then
          vim.list_extend(combined, vim.split(stderr, '\n'))
        end
        if #combined == 0 and output_file_contents then
          vim.list_extend(combined, vim.split(output_file_contents, '\n'))
        end
        vim.list_extend(lines, combined)
        with_header(bufnr, nil, lines)
      else
        write_output(bufnr, opts, output_file_contents)
      end

      pcall(vim.fn.delete, temp_file)
      if temp_collection_root then
        pcall(vim.fn.delete, temp_collection_root, 'rf')
      end
    end)
  end)
end

function M.run()
  local current_file = vim.fn.expand '%:p'
  if current_file ~= '' and vim.fn.fnamemodify(current_file, ':e') == 'bru' then
    run_request(current_file, { mode = 'split' })
    return
  end

  M.run_last()
end

function M.run_last()
  load_persisted_state()
  local last_file = get_cached_bru_file()
  if not last_file then
    vim.notify('No cached Bruno request found. Run a .bru file first.', vim.log.levels.WARN, { title = 'bruno.nvim' })
    return
  end

  run_request(last_file, { mode = 'popup', width = 0.98, height = 0.94 })
end

function M.setup(user_opts)
  M.opts = config.apply(user_opts)
  state.last_raw_output = nil
  setup_highlights()
  load_persisted_state()

  local augroup = vim.api.nvim_create_augroup('bruno.nvim_autocmds', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = augroup,
    callback = setup_highlights,
    desc = 'Refresh bruno.nvim highlight links',
  })

  vim.api.nvim_create_user_command('BrunoRun', M.run, {})
  vim.api.nvim_create_user_command('BrunoRunLast', M.run_last, {})
  vim.api.nvim_create_user_command('BrunoEnv', M.env, {})
  vim.api.nvim_create_user_command('BrunoEnvSet', function(cmd)
    M.set_env(cmd.args)
  end, { nargs = 1 })
  vim.api.nvim_create_user_command('BrunoEnvClear', M.clear_env, {})
  vim.api.nvim_create_user_command('BrunoEnvFromFile', function(cmd)
    M.env_from_file { keypath = cmd.args ~= '' and cmd.args or nil }
  end, { nargs = '?' })
  vim.api.nvim_create_user_command('BrunoEnvFileSet', function(cmd)
    M.set_env_file(cmd.args)
  end, { nargs = 1, complete = 'file' })
  vim.api.nvim_create_user_command('BrunoEnvFilePick', M.env_file_pick, {})
  vim.api.nvim_create_user_command('BrunoEnvFileFromBuffer', M.env_file_from_buffer, {})
  vim.api.nvim_create_user_command('BrunoEnvFileClear', M.clear_env_file, {})
  vim.api.nvim_create_user_command('BrunoAuthSet', function(cmd)
    state.auth_mode = cmd.args
    vim.notify('Bruno auth override set to: ' .. cmd.args, vim.log.levels.INFO, { title = 'bruno.nvim' })
  end, { nargs = 1 })
  vim.api.nvim_create_user_command('BrunoAuthClear', function()
    state.auth_mode = nil
    vim.notify('Bruno auth override cleared (will use file as-is).', vim.log.levels.INFO, { title = 'bruno.nvim' })
  end, {})
  vim.api.nvim_create_user_command('BrunoSearch', M.search, {})
  vim.api.nvim_create_user_command('BrunoToggleFormat', M.toggle_output_format, {})
end

return M
