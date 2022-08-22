nnoremap <silent> <leader>cf <Cmd>GoFmt<CR><Cmd>w<CR>
" nnoremap <silent> <f5> :w<CR>:GoRun<CR>

" convert JSON to GO struct
vnoremap <leader>cf :!quicktype -l go --just-types --top-level 
