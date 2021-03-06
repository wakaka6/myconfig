let g:mapleader="\<Space>"

" unmap ctrl+j as null
let g:BASH_Ctrl_j = 'off'

map S <Cmd>w<CR>
map Q <Cmd>q<CR>

" I don't know why the map not work, so i use the imap xmap and smap to
" replace map.
inoremap <C-q> <ESC>
xnoremap <C-q> <ESC>
snoremap <C-q> <ESC>


" Press space twice to jump to the next '<,.>' and edit it.
noremap <silent> <LEADER><LEADER> <ESC>/<,.><CR>:nohlsearch<CR>"_c4l

nnoremap <silent> <LEADER>\| a<,.><ESC>

" toggle buffer
nnoremap <silent> [b            :bprevious<CR>
nnoremap <silent> ]b            :bnext<CR>
nnoremap <silent> <LEADER>[     :bprevious<CR>
nnoremap <silent> <LEADER>]     :bnext<CR>
nnoremap <silent> [B            :bfirst<CR>
nnoremap <silent> ]B            :blast<CR>

" change better pane move method
nnoremap <silent> <LEADER>h <C-w>h
nnoremap <silent> <LEADER>j <C-w>j
nnoremap <silent> <LEADER>k <C-w>k
nnoremap <silent> <LEADER>l <C-w>l

" resize pane with ALT+arrow
nnoremap <silent> <M-Up>    <Cmd>resize -2<CR>
nnoremap <silent> <M-Down>  <Cmd>resize +2<CR>
nnoremap <silent> <M-Left>  <Cmd>vertical resize -2<CR>
nnoremap <silent> <M-Right> <Cmd>vertical resize +2<CR>

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
nnoremap <silent> <LEADER><CR> :<C-u>nohlsearch<CR><C-l>

" Copy to system clipboard
vnoremap Y "+y

" 0切换行头和首个非空白符号
noremap <expr>0 col('.') == 1 ? '^': '0'

" 寻找中文
nnoremap <silent> <LEADER>fz <ESC>/\v<[\u4e00-\u9fa5]+>/<CR>:nohlsearch<CR>
