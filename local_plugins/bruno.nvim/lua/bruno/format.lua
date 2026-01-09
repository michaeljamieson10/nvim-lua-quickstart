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

function M.pretty_json_lines(value)
  if value == nil or value == vim.NIL then
    return { 'null' }
  end

  if type(value) == 'string' then
    local trimmed = vim.trim(value)
    local ok, decoded = pcall(vim.json.decode, trimmed)
    if ok then
      if type(decoded) == 'table' then
        local pretty = pretty_json_str(vim.json.encode(decoded))
        return vim.split(pretty, '\n', { trimempty = true })
      end

      if type(decoded) == 'string' then
        local inner = decoded
        local inner_trimmed = vim.trim(inner)
        local first = inner_trimmed:sub(1, 1)
        if first == '{' or first == '[' then
          local ok_inner, inner_decoded = pcall(vim.json.decode, inner_trimmed)
          if ok_inner and type(inner_decoded) == 'table' then
            local pretty = pretty_json_str(vim.json.encode(inner_decoded))
            return vim.split(pretty, '\n', { trimempty = true })
          end
        end

        return vim.split(inner, '\n', { plain = true })
      end

      local pretty = pretty_json_str(vim.json.encode(decoded))
      return vim.split(pretty, '\n', { trimempty = true })
    end

    return vim.split(value, '\n', { plain = true })
  end

  local pretty = pretty_json_str(vim.json.encode(value))
  return vim.split(pretty, '\n', { trimempty = true })
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
    for _, line in ipairs(M.pretty_json_lines(response.data)) do
      table.insert(formatted, line)
    end
    table.insert(formatted, '```')
  end

  return formatted
end

return M
