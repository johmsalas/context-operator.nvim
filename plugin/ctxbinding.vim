command! -nargs=1 InvokeCtxBinding lua require("ctxbinding.plugin.plugin").invoke_namespace_commands(<f-args>)

function! ContextKeybindWrapOperatorFunction(trigger) range
  let g:ctxbindingcount = v:count
  let g:ctxbindingtrigger = a:trigger
  lua require("ctxbinding").wrap_operator(vim.g.ctxbindingtrigger, vim.g.ctxbindingcount )
endfunction

command! -nargs=1 ContextKeybindWrapOperator call ContextKeybindWrapOperatorFunction(<q-args>)

function! ContextObjectFunction(namespace) range
  let g:ctxbindingcount = v:count
  let g:ctxbindingnamespace = a:namespace
  lua require("ctxbinding").invoke_namespace_objects(vim.g.ctxbindingnamespace, vim.g.ctxbindingcount)
endfunction

command! -range -nargs=1 ContextObject call ContextObjectFunction(<q-args>)

command! -range CtxBindingOpenTelescope <line1>,<line2>lua require("ctxbinding").open_telescope_commands()

