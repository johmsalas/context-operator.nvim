local utils = require('contextoperator.shared.utils')

local M = {}

function M.build_context(state)
  local cursor_pos = vim.fn.getpos(".")
  local cursor = {
    row = cursor_pos[2],
    col = cursor_pos[3],
  }

  local current_char = utils.nvim_buf_get_text(0,
    cursor.row - 1,
    cursor.col - 1,
    cursor.row - 1,
    cursor.col
  )[1]

  local current_word = utils.get_current_ascii_word(nil, cursor_pos)
  local word_under_cursor = utils.get_current_word(nil, cursor_pos)

  local filetype = vim.filetype

  local operator_trigger = state.operator_trigger

  return {
    cursor = cursor,
    current_word = current_word,
    current_char = current_char,
    filetype = filetype,
    operator_trigger = operator_trigger,
    word_under_cursor = word_under_cursor,
  }
end

return M
