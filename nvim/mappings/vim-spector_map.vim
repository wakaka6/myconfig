

function! s:read_template_into_buffer(template)
    execute '0r ~/.config/nvim/sample_vimspector_json/'.a:template
endfunction
command! -bang -nargs=* LoadVimSpectorJsonTemplate call fzf#run({
            \   'source': 'ls ~/.config/nvim/sample_vimspector_json',
            \   'down': 20,
            \   'sink': function('<sid>read_template_into_buffer')
            \ })
noremap <leader>dc :tabe .vimspector.json<CR>:LoadVimSpectorJsonTemplate<CR>

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
