local M = {}

function M.restore_cursor_pos()
  return function(context)
    local cursor_pos = context.cursor_pos
    vim.schedule(function()
      vim.fn.setpos(".", cursor_pos)
    end)

  end
end

function M.replace_word(old_text)
  return {
    with = function(new_text)
      return {
        {
          verify = M.current_word_is(old_text),
          execute = M.replace_current_word(new_text)
        }
      }
    end
  }
end

function M.replace_current_word(newText)
  return function(context)
    local current_word = context.current_word
    if current_word ~= nil then
      vim.api.nvim_buf_set_text(0,
        current_word.start_pos[2] - 1,
        current_word.start_pos[3] - 1,
        current_word.end_pos[2] - 1,
        current_word.end_pos[3],
        { newText }
      )
    end
  end
end

function M.word_type_is(expectedType)
  return function(context)
    if expectedType == 'symbol' and string.match(context.word_under_cursor.word, "[%a%d_]+") ~= nil then
      return 1
    end
    return 0
  end
end

function M.operator_is(expectedChar)
  return function(context)
    if context.operator_trigger == expectedChar then return 1 end
    return 0
  end
end

function M.current_char_is(expectedChar)
  return function(context)
    if context.current_char == expectedChar then return 1 end
    return 0
  end
end

function M.char_is_in(expectedCharsList)
  local dict = {}
  for _, char in ipairs(expectedCharsList) do
    dict[char] = char
  end
  return function(context)
    if dict[context.current_char] ~= nil then return 1 end
    return 0
  end
end

function M.filetype_is_in(expectedFiletype)
  local dict = {}
  for _, type in ipairs(expectedFiletype) do
    dict[type] = type
  end
  return function(context)
    if dict[context.filetype] ~= nil then return 1 end
    return 0
  end
end

function M.current_word_is(expectedText)
  return function(context)
    if context.current_word == nil then return 0 end

    if context.current_word.word == expectedText then return 1 end
    return 0
  end
end

function M.send_keys(keys, mode, escape_ks)
  escape_ks = escape_ks or false

  return function(context)
    local char = context.current_char
    local count = context.count > 0 and context.count or ''
    local converted_keys = keys:gsub("{char}", char):gsub("{count}", count)

    if (escape_ks == false) then
      converted_keys = vim.api.nvim_replace_termcodes(converted_keys, true, false, true)
    end

    if mode ~= nil then
      vim.api.nvim_feedkeys(converted_keys, mode, escape_ks)
    else
      vim.cmd("normal! " .. converted_keys)
    end
  end
end

function M.replace_in(filetype)
  return {
    from = function(src)
      return {
        to = function(dest)
          return {
            verify = M.current_word_is(src),
            execute = M.replace_current_word(dest),
          }
        end
      }
    end
  }
end

function M.toggle_boolean()
  return {
    {
      verify = M.current_word_is('false'),
      execute = M.replace_current_word('true')
    },
    {
      verify = M.current_word_is('true'),
      execute = M.replace_current_word('false')
    },
    {
      verify = M.current_word_is('FALSE'),
      execute = M.replace_current_word('TRUE')
    },
    {
      verify = M.current_word_is('TRUE'),
      execute = M.replace_current_word('FALSE')
    },
  }
end

function M.toggle_brackets()
  return {
    {
      verify = M.current_char_is('{'),
      execute = M.send_keys('clr{[', 'm'),
    },
    {
      verify = M.current_char_is('['),
      execute = M.send_keys('clr[{', 'm'),
    },
    {
      verify = M.current_char_is('}'),
      execute = M.send_keys('clr{[', 'm'),
    },
    {
      verify = M.current_char_is(']'),
      execute = M.send_keys('clr[{', 'm'),
    }
  }
end

function M.toggle_quotes(quotes)
  local changes = {}

  for i = 1, #quotes, 1 do
    local a = quotes[i]
    local b = (i == #quotes) and quotes[1] or quotes[i + 1]

    table.insert(changes, {
      verify = M.current_char_is(a),
      execute = M.send_keys('clr' .. a .. b, 'm'),
    })
  end

  return changes
end

function M.cycle_words(words)
  local changes = {}

  for i = 1, #words, 1 do
    local a = words[i]
    local b = (i == #words) and words[1] or words[i + 1]

    table.insert(changes, {
      verify = M.current_word_is(a),
      execute = M.replace_current_word(b),
    })
  end

  return changes
end

return M
