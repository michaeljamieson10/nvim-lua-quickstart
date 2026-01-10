local M = {}

local function set_buffer_properties(bufnr, name)
  vim.api.nvim_buf_set_name(bufnr, name)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
  vim.api.nvim_set_option_value('swapfile', false, { buf = bufnr })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
end

local function ensure_close_key(bufnr)
  if vim.b[bufnr].bruno_close_key then
    return
  end

  vim.b[bufnr].bruno_close_key = true
  vim.keymap.set('n', 'q', function()
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = bufnr, silent = true, desc = 'Close Bruno output' })
end

local function resolve_size(value, total, fallback_ratio)
  if not value then
    return math.floor(total * fallback_ratio)
  end
  if value > 0 and value <= 1 then
    return math.floor(total * value)
  end
  return math.floor(value)
end

local function find_window(buffer_name)
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= '' and name:match(buffer_name .. '$') then
      return winid, bufnr
    end
  end
  return nil, nil
end

local function get_or_create_split(opts)
  local buffer_name = opts.buffer_name
  local existing_bufnr = vim.fn.bufnr(buffer_name)
  local width = resolve_size(opts.width, vim.o.columns, 0.5)

  local winid, bufnr = find_window(buffer_name)
  if winid then
    vim.api.nvim_set_current_win(winid)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    pcall(vim.api.nvim_win_set_width, winid, width)
    ensure_close_key(bufnr)
    return bufnr
  end

  vim.cmd 'botright vsplit'
  local new_win = vim.api.nvim_get_current_win()
  pcall(vim.api.nvim_win_set_width, new_win, width)

  if existing_bufnr ~= -1 then
    bufnr = existing_bufnr
    vim.api.nvim_set_current_buf(bufnr)
  else
    bufnr = vim.api.nvim_create_buf(false, true)
    set_buffer_properties(bufnr, buffer_name)
    vim.api.nvim_set_current_buf(bufnr)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  ensure_close_key(bufnr)
  return bufnr
end

local function get_or_create_popup(opts)
  local buffer_name = opts.buffer_name
  local existing_bufnr = vim.fn.bufnr(buffer_name)

  local winid, bufnr = find_window(buffer_name)
  if winid then
    vim.api.nvim_set_current_win(winid)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    ensure_close_key(bufnr)
    return bufnr
  end

  if existing_bufnr ~= -1 then
    bufnr = existing_bufnr
  else
    bufnr = vim.api.nvim_create_buf(false, true)
    set_buffer_properties(bufnr, buffer_name)
  end

  local total_cols = vim.o.columns
  local total_lines = vim.o.lines - vim.o.cmdheight
  local width = resolve_size(opts.width, total_cols, 0.7)
  local height = resolve_size(opts.height, total_lines - 2, 0.7)

  width = math.max(1, math.min(width, total_cols))
  height = math.max(1, math.min(height, total_lines - 2))

  local row = math.floor((total_lines - height) / 2)
  local col = math.floor((total_cols - width) / 2)

  local win_opts = {
    relative = 'editor',
    style = 'minimal',
    row = row,
    col = col,
    width = width,
    height = height,
    border = opts.border,
    zindex = opts.zindex,
  }

  if opts.title and vim.fn.has('nvim-0.9') == 1 then
    win_opts.title = opts.title
    win_opts.title_pos = opts.title_pos or 'center'
  end

  local new_win = vim.api.nvim_open_win(bufnr, true, win_opts)
  vim.api.nvim_set_option_value('winhighlight', 'Normal:NormalFloat,FloatBorder:FloatBorder', { win = new_win })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  ensure_close_key(bufnr)
  return bufnr
end

function M.get_or_create(output)
  local opts = output or {}
  if opts.mode == 'popup' or opts.mode == 'float' then
    return get_or_create_popup(opts)
  end
  return get_or_create_split(opts)
end

function M.close(buffer_name)
  local winid = select(1, find_window(buffer_name))
  if winid then
    vim.api.nvim_win_close(winid, true)
    return true
  end
  return false
end

return M
