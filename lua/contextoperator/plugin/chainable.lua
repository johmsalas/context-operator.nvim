local builtin = require('contextoperator.plugin.builtin')

local M = {}

function CreateTableFromItemsOrTables(items)
  if type(items) ~= 'table' then return { items } end
  local list = {}
  for _, item in ipairs(items) do
    if type(item) == 'table' then
      for _, c in pairs(item) do
        table.insert(list, c)
      end
    else
      table.insert(list, item)
    end
  end

  return list
end

function M._describe(_)
  return {
    _when = M._when
  }
end

function M._when(comparator)
  local when_api = {
    type = 'when_api',
    _actions = {},
    _if = function(nestedComparator)
      local comparators = CreateTableFromItemsOrTables({ comparator, nestedComparator })
      return M._if(comparators)
    end,
    _and = function(nestedComparator)
      local comparators = CreateTableFromItemsOrTables({ comparator, nestedComparator })
      return M._when(comparators)
    end,
    _then = function(allActions)
      return M._then(allActions, comparator)
    end,
    verify = function(context)
      local comparators = CreateTableFromItemsOrTables({ comparator })
      return M.verify(context, comparators)
    end,
    object = function(context)
      Run_actions(actions, context)
    end
  }

  setmetatable(when_api, M.callableObjectTable)

  return when_api
end

M.callableObjectTable = {
  __call = function(self, ...)
    for _, action in pairs(self.actions) do
      -- action(...)
    end
  end
}

function M.verify(context, comparators)
  local validity = 1

  if type(comparators) == 'table' then
    for _, c in pairs(comparators) do
      if c(context) == 0 then
        validity = 0
      end
    end
  else
    if comparators(context) == 0 then
      validity = 0
    end
  end

  return validity
end

function M._if(comparator)
  local if_api = {
    type = 'if_api',
    _actions = {},
    _and = function(nestedComparator)
      local comparators = CreateTableFromItemsOrTables({ comparator, nestedComparator })
      return M._when(comparators)
    end,
    _then = function(allActions)
      return M._if_then(allActions, comparator)
    end,
    _else = function(allActions)
      return M._then(allActions, comparator)
    end,
    verify = function(context)
      local comparators = CreateTableFromItemsOrTables({ comparator })
      return M.verify(context, comparators)
    end,
    object = function(context)
      Run_actions(actions, context)
    end
  }

  setmetatable(if_api, M.callableObjectTable)

  return if_api
end

function M._else(if_actions, else_actions, comparator)
  local if_actions_collection = CreateTableFromItemsOrTables(if_actions)
  local else_actions_collection = CreateTableFromItemsOrTables(else_actions)

  local else_api = {
    actions = if_actions_collection,
    type = 'else_api',
    _and = function(nestedAction)
      local actions = CreateTableFromItemsOrTables({ else_actions_collection, nestedAction })
      return M._else(if_actions, actions, comparator)
    end,
    verify = function(context)
      return 1
    end,
    object = function(context)
      local comparators = CreateTableFromItemsOrTables({ comparator })
      local result = M.verify(context, comparators)
      if result == 1 then
        Run_actions(if_actions_collection, context)
      else
        Run_actions(else_actions_collection, context)
      end
    end
  }

  setmetatable(else_api, M.callableObjectTable)

  return else_api
end

function Run_actions(actions, context)
  for _, action in ipairs(actions) do
    action(context)
  end
end

function M._if_then(all_actions, comparator)
  local actions = CreateTableFromItemsOrTables(all_actions)

  local then_api = {
    type = 'if_then_api',
    actions = actions,
    _and = function(nestedAction)
      return M._then({ all_actions, nestedAction }, comparator)
    end,
    _else = function(else_actions)
      return M._else(all_actions, else_actions, comparator)
    end,
    verify = function(context)
      local comparators = CreateTableFromItemsOrTables({ comparator })
      return M.verify(context, comparators)
    end,
    object = function(context)
      Run_actions(actions, context)
    end
  }

  setmetatable(then_api, M.callableObjectTable)

  return then_api
end

function M._then(allActions, comparator)
  local actions = CreateTableFromItemsOrTables(allActions)

  local then_api = {
    type = 'then_api',
    actions = actions,
    _and = function(nestedAction)
      return M._then({ allActions, nestedAction }, comparator)
    end,
    verify = function(context)
      local comparators = CreateTableFromItemsOrTables({ comparator })
      return M.verify(context, comparators)
    end,
    object = function(context)
      Run_actions(actions, context)
    end
  }

  setmetatable(then_api, M.callableObjectTable)

  return then_api
end

return M
