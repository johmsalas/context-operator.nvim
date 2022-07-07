local plugin = require('contextoperator.plugin.plugin')
local builtin = require('contextoperator.plugin.builtin')

local M = {
  builtin = {
    validator = {
      current_word_is = builtin.current_word_is,
    },
    command = {
      replace_current_word = builtin.replace_current_word
    },
    preset = {
      toggle_boolean = builtin.toggle_boolean
    }
  },
  register_commands = plugin.register_commands,
}

return M
