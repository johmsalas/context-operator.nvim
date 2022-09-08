local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local plugin = require('contextoperator.plugin.plugin')

local function invoke_command(prompt_bufnr)
  return function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local change = selection.value
    vim.pretty_print(change)
  end
end

local function invoke_object(prompt_bufnr)
  -- objects can't be invoked
end

local function telescope_context_operator_commands(opts)
  opts = opts or require("telescope.themes").get_cursor()

  local results = {}
  local k = 1
  vim.pretty_print(plugin.get_state().commands_by_namespace)
  for _, v in pairs(plugin.get_state().commands_by_namespace) do
    results[k] = v
    k = k + 1
  end

  require("telescope.pickers").new(opts, {
    prompt_title = "Invoke contextual command",
    finder = require("telescope.finders").new_table({
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = require("telescope.config").values.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local curried_method = invoke_command(prompt_bufnr)
      map("i", "<CR>", curried_method)
      map("n", "<CR>", curried_method)
      return true
    end,
  }):find()
end

return require("telescope").register_extension({
  exports = {
    commands = telescope_context_operator_commands,
  },
})
