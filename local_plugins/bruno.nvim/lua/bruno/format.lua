local M = {}

local function is_not_nil(value)
  return value ~= nil and value ~= vim.NIL
end

local function is_json_null(value)
  return value == nil or value == vim.NIL
end

local function pretty_json_str(s, indent)
  indent = indent or '  '
  local out, level, in_str, esc = {}, 0, false, false

  for i = 1, #s do
    local ch = s:sub(i, i)
    if in_str then
      out[#out + 1] = ch
      if esc then
        esc = false
      elseif ch == '\\' then
        esc = true
      elseif ch == '"' then
        in_str = false
      end
    else
      if ch == '"' then
        in_str = true
        out[#out + 1] = ch
      elseif ch == '{' or ch == '[' then
        out[#out + 1] = ch .. '\n' .. string.rep(indent, level + 1)
        level = level + 1
      elseif ch == '}' or ch == ']' then
        level = level - 1
        out[#out + 1] = '\n' .. string.rep(indent, level) .. ch
      elseif ch == ',' then
        out[#out + 1] = ch .. '\n' .. string.rep(indent, level)
      elseif ch == ':' then
        out[#out + 1] = ': '
      elseif not ch:match('%s') then
        out[#out + 1] = ch
      end
    end
  end

  return table.concat(out)
end

function M.format_bruno_output(raw_output)
  local ok, data = pcall(vim.json.decode, raw_output)
  if not ok or not data or not data.results or #data.results == 0 then
    return vim.split(raw_output, '\n')
  end

  local formatted = {}
  local result = data.results[1] or {}
  local request = result.request or {}
  local response = result.response or {}

  table.insert(formatted, 'REQUEST DETAILS:')
  table.insert(formatted, string.format('  Method: %s', tostring(request.method or '(unknown)')))
  table.insert(formatted, string.format('  URL: %s', tostring(request.url or '(unknown)')))
  table.insert(formatted, '')

  table.insert(formatted, 'RESPONSE:')
  if is_not_nil(result.error) then
    table.insert(formatted, string.format('  Error: %s', tostring(result.error)))
  end

  local status_text = is_not_nil(response.statusText) and (' ' .. tostring(response.statusText)) or ''
  table.insert(formatted, string.format('  Status: %s%s', tostring(response.status or '(no status)'), status_text))
  if is_not_nil(response.responseTime) then
    table.insert(formatted, string.format('  Response Time: %dms', response.responseTime))
  end
  table.insert(formatted, '')

  if is_not_nil(response.data) then
    table.insert(formatted, 'RESPONSE DATA:')
    table.insert(formatted, '```json')

    local data_content = is_json_null(response.data) and 'null' or pretty_json_str(vim.json.encode(response.data))
    for _, line in ipairs(vim.split(data_content, '\n', { trimempty = true })) do
      table.insert(formatted, line)
    end

    table.insert(formatted, '```')
  end

  return formatted
end

function M.pretty_json_lines(value)
  local encoded = 'null'
  if value ~= nil and value ~= vim.NIL then
    encoded = vim.json.encode(value)
  end
  local pretty = pretty_json_str(encoded)
  return vim.split(pretty, '\n', { trimempty = true })
end

return M
