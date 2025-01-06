local M = {}
function M.setup()
  -- Define highlight groups
  vim.cmd [[
    highlight SchemaFieldKey guifg=Yellow
    highlight SchemaFunction guifg=Green
    highlight SchemaSpecialString guifg=Cyan
    highlight SchemaComment guifg=Grey
    highlight SchemaCurlyBrace guifg=Blue
]]

  -- Add syntax matching for custom highlights
  vim.api.nvim_exec(
    [[
    syntax match SchemaFieldKey /"\(model\|schema\|fields\|label\|type\|inputType\|model\|required\|validator\)":/
    syntax match SchemaFunction /\<function\s*(.*)\s*{/
    syntax match SchemaSpecialString /\<\(required\|visible\|validator\)\>/
    syntax match SchemaComment /\/\/.*/
    syntax match SchemaCurlyBrace /[{}]/
]],
    false
  )

  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = 'Z:/Data Management/*.json',
    callback = function()
      vim.bo.filetype = 'javascript'
      vim.cmd [[setlocal syntax=off]]
      vim.diagnostic.enable(false) -- Disables diagnostics for the current buffer
    end,
  })
end
return {
  M.setup(),
}
