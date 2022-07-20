local plugin = require('contextoperator.plugin.plugin')
local builtin = require('contextoperator.plugin.builtin')
local chainable = require('contextoperator.plugin.chainable')

local M = {
  lang = {
    _when = chainable._when,
    _if = chainable._if,
    _then = chainable._then,
    _else = chainable._else,
    _describe = chainable._describe,
    operator_is = builtin.operator_is,
    current_char_is = builtin.current_char_is,
    word_type_is = builtin.word_type_is,
    send_keys = builtin.send_keys,
    char_is_in = builtin.char_is_in,
  },
  builtin = {
    validator = {
      current_word_is = builtin.current_word_is,
      current_char_is = builtin.current_char_is,
    },
    command = {
      replace_current_word = builtin.replace_current_word,
      send_keys = builtin.send_keys
    },
    preset = {
      toggle_boolean = builtin.toggle_boolean,
      toggle_brackets = builtin.toggle_brackets,
    }
  },
  register_commands = plugin.register_commands,
  register_objects = plugin.register_objects,
  wrap_operator = plugin.wrap_operator,
  invoke_namespace_objects = plugin.invoke_namespace_objects,
}

return M
