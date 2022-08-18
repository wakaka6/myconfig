" *****
" coc.nvim
" *****
let g:coc_global_extensions = ['coc-json', 
			\ 'coc-vimlsp', 
			\ 'coc-pyright', 
			\ 'coc-clangd', 
			\ 'coc-sh', 
			\ 'coc-cmake',
			\ 'coc-git',
			\ 'coc-ultisnips',
			\ 'coc-vimtex',
			\ 'coc-translator',
			\ 'coc-explorer']
set shortmess+=c

			" \ 'coc-snippets',

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" delay 300ms start coc
let g:coc_start_at_startup=0
function! CocTimerStart(timer)
    exec "CocStart"
endfunction
call timer_start(300,'CocTimerStart',{'repeat':1})


"解决coc.nvim大文件卡死状况
let g:trigger_size = 0.5 * 1048576

augroup hugefile
  autocmd!
  autocmd BufReadPre *
        \ let size = getfsize(expand('<afile>')) |
        \ if (size > g:trigger_size) || (size == -2) |
        \   echohl WarningMsg | echomsg 'WARNING: altering options for this huge file!' | echohl None |
        \   exec 'CocDisable' |
        \ else |
        \   exec 'CocEnable' |
        \ endif |
        \ unlet size
augroup END

