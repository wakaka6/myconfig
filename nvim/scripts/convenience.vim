au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" no highlight current line when terminal
au TermLeave * set cursorline
au TermEnter * set nocursorline

" hexeditor on vim. look at `h hex-editing`.
augroup Binary
    au!
    au BufReadPre  *.bin let &bin=1
    au BufReadPost *.bin if &bin | %!xxd
    au BufReadPost *.bin set ft=xxd | endif
    au BufWritePre *.bin if &bin | %!xxd -r
    au BufWritePre *.bin endif
    au BufWritePost *.bin if &bin | %!xxd
    au BufWritePost *.bin set nomod | endif
augroup END

" create like vscode launch.json to debug code
" require fzf.vim
function! s:read_template_into_buffer(template)
    execute '0r ~/.config/nvim/sample_debug_json/'.a:template
endfunction
command! -bang -nargs=* LoadDebugLaunchJsonTemplate call fzf#run({
            \   'source': 'ls ~/.config/nvim/sample_debug_json',
            \   'down': 20,
            \   'sink': function('<sid>read_template_into_buffer')
            \ })
