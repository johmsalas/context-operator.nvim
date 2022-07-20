command! -nargs=1 InvokeContextOperator lua require("contextoperator.plugin.plugin").invoke_namespace_commands(<f-args>)
command! -nargs=1 ContextKeybindWrapOperator lua require("contextoperator.plugin.plugin").wrap_operator(<f-args>)
