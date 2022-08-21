

noremap <leader>dc <Cmd>tabe .vimspector.json<CR><Cmd>LoadVimSpectorJsonTemplate<CR>

nmap <LocalLeader><F11> <Plug>VimspectorUpFrame
nmap <LocalLeader><F12> <Plug>VimspectorDownFrame
nmap <Leader>db <Plug>VimspectorBreakpoints

" quit vimspector
nmap <Leader>dq <Cmd>VimspectorReset<CR>

nmap <Leader>dl <Cmd>VimspectorToggleLog<CR>

" debug spector
" for normal mode - the word under the cursor
nmap <Leader>di <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xmap <Leader>di <Plug>VimspectorBalloonEval
