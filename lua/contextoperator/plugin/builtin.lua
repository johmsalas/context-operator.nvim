local M = {}

function M.replace_current_word(newText)
  return function(context)
    vim.api.nvim_buf_set_text(0,
      context.cursor.row - 1,
      context.cursor.col - 1,
      context.cursor.row - 1,
      context.cursor.col - 1 + #context.current_word,
      newText
    )
  end
end

function M.current_word_is(expectedText)
  return function(context)
    if context.current_word == expectedText then return true end
    return false
  end
end

function M.toggle_boolean()
  return {
    {
      verify = M.validate_current_word('false'),
      execute = M.replace_current_word('true')
    },
    {
      verify = M.validate_current_word('true'),
      execute = M.replace_current_word('false')
    },
    {
      verify = M.validate_current_word('FALSE'),
      execute = M.replace_current_word('TRUE')
    },
    {
      verify = M.validate_current_word('TRUE'),
      execute = M.replace_current_word('FALSE')
    },
  }
end

return M
