# Programmable bindings

A Neovim plugin for declaring several commands or objects to the same key-binding. Only the first command matching a criteria is executed. In the case of an object, only the first object matching the criteria is selected

The criteria for executing the command (or selecting the object) is based on the current context, which is Lazy loaded (WIP). The context is a set of values including word under cursor, cursor position, current operator, filetype, char under cursor and it is open to add more lazy loaded attributes (See the list here)

Warning: This plugin is under construction. Having said that, I'm going to encourage its usage. I need your feedback to understand how you plan to use it and what is missing.

## Custom Objects

`register_objects` adds under a namespace several possible matching object.

The following example registers 3 possible objects for the namespace `word` and, instead of adding a key map for a new object, it overrides the existing `w`

In the example, the custom object is the collection of 3 possibilities:

1. If the current operator is remove (`d`) and the character under cursor is any of ', '[', "'", '"', '(' or "<" then trigger another plugin to remove the brackets, in this case vim-sandwich removal
2. Similar to the previous one, but given the change (`c`) operator. Use a different set of keys to trigger vim-sandwich change
3. Otherwise, use regular w selection

```lua
-- Programmable keybind: word (object)
-- Modify w object. Invokes vim-sandwich when there is a bracket or similar wrapper
local supported_wrappers = { '{', '[', "'", '"', '(', "<" }
co.register_objects('word', {
  _when(operator_is('d'))
      ._and(char_is_in(supported_wrappers))
      ._then(send_keys("cld{char}", 't'))
  ,
  _when(operator_is('c'))
      ._and(char_is_in(supported_wrappers))
      ._then(send_keys('clr{char}', 'mtix!'))
      ._and(send_keys('"_yy', 'm'))
  , send_keys("{count}w")
})

vim.api.nvim_set_keymap('x', 'w', ':<c-u>contextObject word<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('o', 'w', ':<c-u>ContextObject word<cr>', { noremap = true, silent = true })
```

## Custom Commands

`register_commands` adds under a namespace several possible matching commands.

A use case would be a "quick_change" command that groups under the same keybinding quick actions, but it only executes the first matching command

In the following example, it adds a `cycle quotes` feature for TypeScript, taking into account 3 different types of quotes, and default to 2 types of quotes for other filetypes. It includes toggling booleans (with a preset method) and toggling brackets

```lua
-- Programmable keybind: quick_change (command)
-- Give a keybinding different purposes according to the context
co.register_commands('quick_change', {
  _when(filetype_is_in({ 'typescript', 'typescriptreact' }))
      ._attempt(fun.toggle_quotes({ '"', "'", '`' }))
      ._and(restore_cursor_pos())

  , fun.toggle_boolean
  , fun.toggle_brackets
  , fun.toggle_quotes({ '"', "'" })
})

vim.api.nvim_set_keymap('n', '<Leader>i', ':InvokeContextOperator quick_change<CR>', { desc = "Quick Change" })
```

## Project status

Experimental and gathering feedback. There are many edge and use cases to consider. I'm looking forward to read your ideas. How do you plan to use Programmable Bindings?

Expect API changes. Will try to limit them and gracefully depreciate API. But also will try to improve it as much as possible given your feedback.
