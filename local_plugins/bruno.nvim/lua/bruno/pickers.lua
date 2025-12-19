local M = {}

function M.search(search_dirs, picker, prompt)
  prompt = prompt or 'Bruno Files'

  if picker == 'fzf-lua' then
    local fzf = require 'fzf-lua'
    fzf.live_grep {
      prompt = prompt .. ': ',
      search_paths = search_dirs,
      rg_opts = '--column --line-number --no-heading --color=always --smart-case --glob=*.bru',
      actions = {
        ['default'] = function(selected)
          local raw = selected and selected[1] or nil
          if not raw then
            return
          end
          local line = raw:gsub('^[^~/]*', '')
          local file = line:match('^([^:]+)')
          if not file then
            return
          end
          local expanded_path = vim.fs.normalize(vim.fn.expand(file))
          vim.cmd('edit ' .. vim.fn.fnameescape(expanded_path))
        end,
      },
    }
    return
  end

  if picker == 'snacks' then
    local snacks = require 'snacks'
    snacks.picker.grep {
      prompt = prompt .. ': ',
      glob = '*.bru',
      dirs = search_dirs,
      on_select = function(item)
        if item and item.file then
          vim.cmd('edit ' .. item.file)
        end
      end,
    }
    return
  end

  local telescope = require 'telescope.builtin'
  local action_state = require 'telescope.actions.state'
  local actions = require 'telescope.actions'
  telescope.live_grep {
    prompt_title = prompt,
    search_dirs = search_dirs,
    glob_pattern = '*.bru',
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection and selection.filename then
          vim.cmd('edit ' .. selection.filename)
        end
      end)
      return true
    end,
  }
end

function M.pick_env(env_names, picker, prompt, on_select)
  prompt = prompt or 'Bruno Environments'

  if picker == 'fzf-lua' then
    local fzf = require 'fzf-lua'
    fzf.fzf_exec(env_names, {
      prompt = prompt .. ': ',
      actions = {
        ['default'] = function(selected)
          local env = selected and selected[1] or nil
          if env then
            on_select(env)
          end
        end,
      },
    })
    return
  end

  if picker == 'snacks' then
    local snacks = require 'snacks'
    snacks.picker.select(env_names, { prompt = prompt .. ': ' }, function(selected_item)
      if selected_item then
        on_select(selected_item)
      end
    end)
    return
  end

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  pickers
    .new({}, {
      prompt_title = prompt,
      finder = finders.new_table { results = env_names },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local env = selection and selection[1] or nil
          if env then
            on_select(env)
          end
        end)
        return true
      end,
    })
    :find()
end

return M

