local M = {}

function M.expand_atts_in_table()
  return function(context)
    if context.current_word == expectedText then return 1 end
    return 0
  end
end

return M
