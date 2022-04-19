let g:mapleader="\<Space>"

" unmap ctrl+j as null
let g:BASH_Ctrl_j = 'off'

map S :w<CR>
map Q :q<CR>

" Press space twice to jump to the next '<,.>' and edit it.
map <silent> <LEADER><LEADER> <ESC>/<,.><CR>:nohlsearch<CR>"_c4l

nnoremap <silent> <LEADER>\| a<,.><ESC>

" toggle buffer
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>

" change vim windows
nnoremap <silent> <LEADER>h <C-w>h
nnoremap <silent> <LEADER>j <C-w>j
nnoremap <silent> <LEADER>k <C-w>k
nnoremap <silent> <LEADER>l <C-w>l


" Command Mode Cursor Movement
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
" Insert Mode Cursor Movement
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-b> <Left>
inoremap <C-f> <Right>

" Indentation
nnoremap < <<
nnoremap > >>

" search
noremap <LEADER><CR> :nohlsearch<CR>

" Copy to system clipboard
vnoremap Y "+y

" 0切换行头和首个非空白符号
noremap <expr>0 col('.') == 1 ? '^': '0'

