local M = {}

function M.build_context()
  local cursor_pos = vim.fn.getpos(".")
  local cursor = {
    row = cursor_pos[1],
    col = cursor_pos[2],
  }

  local current_word = vim.fn.expand('<cword>')

  return {
    cursor = cursor,
    current_word = current_word,
  }
end

return M
