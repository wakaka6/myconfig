" ******
" theme config
" ******
if (has("termguicolors"))
 set termguicolors
endif
syntax enable

let g:airline_theme='dracula'
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

set t_Co=256      "在windows中用xshell连接打开vim可以显示色彩
" enable tabline
let g:airline#extensions#tabline#enabled = 0
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''

" enable powerline fonts
let g:airline_left_sep = ''
let g:airline_right_sep = ''

