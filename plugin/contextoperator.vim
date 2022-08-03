command! -nargs=1 InvokeContextOperator lua require("contextoperator.plugin.plugin").invoke_namespace_commands(<f-args>)

function! ContextKeybindWrapOperatorFunction(trigger) range
  let g:contextoperatorcount = v:count
  let g:contextoperatortrigger = a:trigger
  lua require("contextoperator").wrap_operator(vim.g.contextoperatortrigger, vim.g.contextoperatorcount )
endfunction

command! -range -nargs=1 ContextKeybindWrapOperator <line1>,<line2>call ContextKeybindWrapOperatorFunction(<q-args>)

function! ContextObjectFunction(namespace) range
  let g:contextoperatorcount = v:count
  let g:contextoperatornamespace = a:namespace
  lua require("contextoperator").invoke_namespace_objects(vim.g.contextoperatornamespace, vim.g.contextoperatorcount)
endfunction

command! -range -nargs=1 ContextObject <line1>,<line2>call ContextObjectFunction(<q-args>)
