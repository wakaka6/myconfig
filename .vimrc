" ********
" Global Config
" ********
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set tabstop=4
set shiftwidth=4
set expandtab  " using space relace tab

" auto search highlight
syntax enable
exec "nohlsearch"
set hlsearch
set incsearch

set autoindent
set clipboard+=unnamed
set ruler
set showcmd

set foldenable " 允许折叠 
set foldmethod=syntax " 手动折叠 
set foldlevel=100

set updatetime=100

" 显示行号
set number
set relativenumber

" 保持屏幕上下总显示5行
set scrolloff=5

" 在命令模式用tab提供选择菜单
set wildmenu

" add suport for plugin
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on


" 显示中文帮助
if version >= 603
    set helplang=cn
    set encoding=utf-8
endif

" 新建.c,.h,.sh,.java, .py文件，自动插入文件头 
autocmd BufNewFile *.cpp,*.[ch],*.sh,*.java,*.py exec ":call AutoSetTitle()" 
autocmd BufEnter *.cpp,*.[ch],*.sh,*.java,*.py exec ":set nu" 
" 定义函数AutoSetTitle，自动插入文件头 
func AutoSetTitle() 
	" 如果文件类型为.sh文件 
	if &filetype == 'sh' 
		call setline(1, "\#!/bin/bash") 
		call append(line("."), "")
		normal G
        normal o
	endif
	
	if &filetype == 'cpp'
		call setline(1, "#include <iostream>")
		call append(line("."), "using namespace std;")
		call append(line(".")+1, "")
		call append(line(".")+2, "int main(int argc, char* argv[])")
		call append(line(".")+3, "{")
		call append(line(".")+4, "	")
		call append(line(".")+5, "	return 0;")
		call append(line(".")+6, "}")
		normal! 6GA
	endif
	if &filetype == 'c'
		call setline(1, "#include <stdio.h>")
		call append(line("."), "#include <stdlib.h>")
		call append(line(".")+1, "")
		call append(line(".")+2, "int main(int argc, char* argv[])")
		call append(line(".")+3, "{")
		call append(line(".")+4, "	")
		call append(line(".")+5, "	return 0;")
		call append(line(".")+6, "}")
		normal! 6GA
	endif

	if &filetype == 'python'
		call setline(1, "\#!/usr/bin/env python")
		call append(line(".")+0, "\# encoding: utf-8")
		normal G
		normal o
		normal o
	endif
	
endfunc 


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
noremap <silent> <LEADER><CR> :nohlsearch<CR>

" Copy to system clipboard
vnoremap Y "+y

" 0切换行头和首个非空白符号
noremap <expr>0 col('.') == 1 ? '^': '0'

" 寻找中文
nnoremap <silent> <LEADER>fz <ESC>/\v<[\u4e00-\u9fa5]+>/<CR>:nohlsearch<CR>

autocmd BufWritePost $MYVIMRC source $MYVIMRC
