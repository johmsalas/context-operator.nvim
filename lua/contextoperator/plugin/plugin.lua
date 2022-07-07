local M = {}

local contextoperator = require('contextoperator.plugin.context')

M.state = {
  commandsByNamespace = {}
}

function M.register_commands(namespace, commands)
  M.state.commandsByNamespace[namespace] = commands;
end

function M.invoke_namespace_commands(namespace)
  local commands = M.state.commandsByNamespace[namespace];
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
