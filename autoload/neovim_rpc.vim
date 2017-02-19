
if has('python3')
  let s:py_cmd = 'python3'
  let s:pyfile_cmd = 'py3file'
elseif has('python')
  let s:py_cmd = 'python'
  let s:pyfile_cmd = 'pyfile'
endif

let g:_nvim_rpc_main_channel = -1
let g:_nvim_rpc_jobs = {}

func! neovim_rpc#serveraddr()
	if exists('g:_neovim_rpc_address')
		return g:_neovim_rpc_address
	endif

	execute s:py_cmd 'import neovim_rpc_server'
	execute s:py_cmd 'neovim_rpc_server.start()'

	let g:_nvim_rpc_main_channel = ch_open(g:_neovim_rpc_main_address)

	" close channel before vim exit
	au VimLeavePre *  call ch_close(g:_nvim_rpc_main_channel) | execute s:py_cmd 'neovim_rpc_server.stop()'

	" identify myself
	call ch_sendexpr(g:_nvim_rpc_main_channel,'neovim_rpc_setup')

	return g:_neovim_rpc_address
endfunc

func! neovim_rpc#jobstart(cmd,opts)
	let g:_neovim_rpc_tmp_cmd  = a:cmd
	let g:_neovim_rpc_tmp_opts = a:cmd
	execute s:py_cmd 'neovim_rpc_server.jobstart()'
	if g:_neovim_rpc_tmp_ret>0
		" g:_neovim_rpc_tmp_ret is the jobid
		" remember options
		let g:_nvim_rpc_jobs[g:_neovim_rpc_tmp_ret . ''] = {'cmd': a:cmd, 'opts':a:opts}
	endif
	return g:_neovim_rpc_tmp_ret
endfunc

func! neovim_rpc#_callback()
	execute s:py_cmd 'neovim_rpc_server.process_pending_requests()'
endfunc

