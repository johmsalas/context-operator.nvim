local M = {}

local contextoperator = require('contextoperator.plugin.context')

M.state = {
  commands_counter = 0,
  commands_by_namespace = {},
  objects_counter = 0,
  objects_by_namespace = {},
  operator_trigger = nil,
}

function M.register_commands(namespace, commandsOrFunc)
  local commands = type(commandsOrFunc) == 'function' and commandsOrFunc() or commandsOrFunc
  if M.state.commands_by_namespace[namespace] == nil then
    M.state.commands_by_namespace[namespace] = {}
  end
  if type(commands) == 'table' and commands.verify == nil and commands.execute == nil then
    for _, subcommands in ipairs(commands) do
      M.register_commands(namespace, subcommands)
    end
  elseif commands.verify ~= nil and commands.execute ~= nil then
    M.state.commands_counter = M.state.commands_counter + 1
    M.state.commands_by_namespace[namespace][M.state.commands_counter] = commands;
  end
end

function M.register_objects(namespace, objectsOrFunc)
  -- if (objectsOrFunc == nil) then return nil end

  -- local objects = type(objectsOrFunc) == 'function'
  --     and objectsOrFunc.type ~= nil and objectsOrFunc() or objectsOrFunc
  local objects = objectsOrFunc

  if M.state.objects_by_namespace[namespace] == nil then
    M.state.objects_by_namespace[namespace] = {}
  end

  if type(objects) == 'table' and objects.verify == nil and objects.execute == nil then
    for _, subobjects in ipairs(objects) do
      M.register_objects(namespace, subobjects)
    end
  elseif type(objects) == 'function' then
    M.state.objects_counter = M.state.objects_counter + 1
    M.state.objects_by_namespace[namespace][M.state.objects_counter] = {
      verify = function() return 1 end,
      execute = objects
    };
  elseif objects.verify ~= nil and objects.execute ~= nil then
    M.state.objects_counter = M.state.objects_counter + 1
    M.state.objects_by_namespace[namespace][M.state.objects_counter] = objects;
  end
end

function M.wrap_operator(trigger, count)
  M.state.operator_trigger = trigger
  local count_prefix = count > 1 and count or ''

  vim.api.nvim_feedkeys(count_prefix .. trigger, 'in', false)
end

function M.run_wrapped_operator(obj)
  return function()
    local trigger = M.state.operator_trigger
    vim.api.nvim_feedkeys(trigger .. obj, 'm', false)
  end
end

function M.invoke_namespace_commands(namespace)
  if M.state.commands_by_namespace[namespace] == nil then
    print('Namespace "' .. namespace .. '" not registered')
    return
  end

  local commands = M.state.commands_by_namespace[namespace];
  local context = contextoperator.build_context(M.state)
  local closest = {
    likeness = 0,
    command = nil
  };

  for _, command in ipairs(commands) do
    local likeness = command.verify(context)
    if likeness == 1 then
      command.execute(context);
      closest.likeness = 0
      break
    else
      closest.likeness = likeness;
      closest.command = command;
    end
  end

  if closest.likeness == 1 then
    closest.command.execute(context);
  end
end

function M.invoke_namespace_objects(namespace, count)
  if M.state.objects_by_namespace[namespace] == nil then
    print('Namespace "' .. namespace .. '" not registered')
    return
  end

  local objects = M.state.objects_by_namespace[namespace];
  local context = contextoperator.build_context(M.state, {
    count = count
  })
  local closest = {
    likeness = 0,
    object = nil
  };

  for _, object in ipairs(objects) do
    local likeness = object.verify(context)
    if likeness == 1 then
      object.execute(context);
      closest.likeness = 0
      break
    else
      closest.likeness = likeness;
      closest.execute = object;
    end
  end

  if closest.likeness == 1 then
    closest.object.execute(context);
  end
end

return M
