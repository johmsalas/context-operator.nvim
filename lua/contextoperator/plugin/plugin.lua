local M = {}

local contextoperator = require('contextoperator.plugin.context')

M.state = {
  commands_counter = 0,
  commands_by_namespace = {}
}

function M.register_commands(namespace, commands)
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

function M.invoke_namespace_commands(namespace)
  if M.state.commands_by_namespace[namespace] == nil then
    print('Namespace "' .. namespace .. '" not registered')
    return
  end

  local commands = M.state.commands_by_namespace[namespace];
  local context = contextoperator.build_context()
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

return M
