local M = {}

local function has_vim_system()
  return type(vim.system) == 'function'
end

function M.run(args, opts, on_done)
  opts = opts or {}

  if has_vim_system() then
    vim.system(args, { cwd = opts.cwd, text = true }, function(result)
      on_done(result.code or 0, result.stdout or '', result.stderr or '')
    end)
    return
  end

  local stdout_chunks = {}
  local stderr_chunks = {}

  local function append(tbl, _, data)
    if not data then
      return
    end
    for _, line in ipairs(data) do
      if line ~= '' then
        table.insert(tbl, line)
      end
    end
  end

  vim.fn.jobstart(args, {
    cwd = opts.cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(...) append(stdout_chunks, ...) end,
    on_stderr = function(...) append(stderr_chunks, ...) end,
    on_exit = function(_, code)
      on_done(code, table.concat(stdout_chunks, '\n'), table.concat(stderr_chunks, '\n'))
    end,
  })
end

return M

