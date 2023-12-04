local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local plugin = require("ctxbinding.plugin.plugin")

local function invoke_command(prompt_bufnr)
  return function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local change = selection.value
  end
end

local function invoke_object(prompt_bufnr)
  -- objects can't be invoked
end

local function telescope_ctx_binding_commands(opts)
  opts = opts or require("telescope.themes").get_cursor()

  local results = {}
  local k = 1
  for _, v in pairs(plugin.get_state().commands_by_namespace) do
    results[k] = v
    k = k + 1
  end

  require("telescope.pickers")
    .new(opts, {
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
    })
    :find()
end

return require("telescope").register_extension({
  exports = {
    commands = telescope_ctx_binding_commands,
  },
})
