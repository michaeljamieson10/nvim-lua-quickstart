local M = {}

local function set_buffer_properties(bufnr, name)
  vim.api.nvim_buf_set_name(bufnr, name)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
  vim.api.nvim_set_option_value('swapfile', false, { buf = bufnr })
end

function M.get_or_create(buffer_name, width)
  local existing_bufnr = vim.fn.bufnr(buffer_name)

  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    if vim.api.nvim_buf_get_name(bufnr):match(buffer_name .. '$') then
      vim.api.nvim_set_current_win(winid)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
      return bufnr
    end
  end

  vim.cmd 'botright vsplit'
  vim.cmd(('vertical resize %d'):format(width or 80))

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
  return bufnr
end

return M
