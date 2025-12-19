local M = {}

local function set_buffer_properties(bufnr, name)
  vim.api.nvim_buf_set_name(bufnr, name)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
  vim.api.nvim_set_option_value('swapfile', false, { buf = bufnr })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
end

function M.get_or_create(buffer_name, width)
  local existing_bufnr = vim.fn.bufnr(buffer_name)
  local function resolve_width(value)
    if not value then
      return math.floor(vim.o.columns * 0.5)
    end
    if value > 0 and value <= 1 then
      return math.floor(vim.o.columns * value)
    end
    return math.floor(value)
  end

  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    if vim.api.nvim_buf_get_name(bufnr):match(buffer_name .. '$') then
      vim.api.nvim_set_current_win(winid)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
      pcall(vim.api.nvim_win_set_width, winid, resolve_width(width))
      return bufnr
    end
  end

  vim.cmd 'botright vsplit'
  local winid = vim.api.nvim_get_current_win()
  pcall(vim.api.nvim_win_set_width, winid, resolve_width(width))

  local bufnr
  if existing_bufnr ~= -1 then
    bufnr = existing_bufnr
    vim.api.nvim_set_current_buf(bufnr)
  else
    bufnr = vim.api.nvim_create_buf(false, true)
    set_buffer_properties(bufnr, buffer_name)
    vim.api.nvim_set_current_buf(bufnr)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true })
  return bufnr
end

return M
