let g:mapleader="\<Space>"

map S :w<CR>
map Q :q<CR>

" Press space twice to jump to the next '<,.>' and edit it.
map <silent> <LEADER><LEADER> <ESC>/<,.><CR>:nohlsearch<CR>"_c4l

" toggle buffer
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>
