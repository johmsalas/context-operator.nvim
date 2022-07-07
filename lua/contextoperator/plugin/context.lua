local M = {}

function M.build_context()
  local cursor_pos = vim.fn.getpos(".")
  local cursor = {
    row = cursor_pos[2],
    col = cursor_pos[3],
  }

  local current_word = vim.fn.expand('<cword>')

  return {
    cursor = cursor,
    current_word = current_word,
  }
end

return M
