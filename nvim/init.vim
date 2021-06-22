set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set tabstop=4
set shiftwidth=4
syntax enable
set hlsearch
set incsearch
set autoindent
set paste
set clipboard+=unnamed
set ruler
set showcmd
set foldenable " 允许折叠 
set foldmethod=manual " 手动折叠 
filetype plugin indent on

call plug#begin(stdpath('data').'/plugged')
	" Plugin Section

	" theme
	Plug 'dracula/vim'
	Plug 'morhetz/gruvbox'
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'

	" file explore that press ctrl+b
	Plug 'scrooloose/nerdtree'
	Plug 'ryanoasis/vim-devicons'

	" automatic completion
	Plug 'zchee/deoplete-jedi'

call plug#end()


" Config Section
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Toggle
nnoremap <silent> <C-b> :NERDTreeToggle<CR>

if (has("termguicolors"))
 set termguicolors
endif
syntax enable
colorscheme dracula

let g:airline_theme='light'
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

autocmd BufNewFile *.cpp,*.[ch],*.sh,*.java,*.py exec ":call AutoSetTitle()" 
func AutoSetTitle() 
	if &filetype == 'sh' 
		call setline(1, "\#!/bin/bash") 
		normal o
		normal o
		normal G
	endif
	
	if &filetype == 'cpp'
		call setline(1, "#include<iostream>")
		call append(line("."), "using namespace std;")
		call append(line(".")+1, "")
		call append(line(".")+2, "int main(int argv, char* argc[])")
		call append(line(".")+3, "{")
		call append(line(".")+4, "	")
		call append(line(".")+5, "	return 0;")
		call append(line(".")+6, "}")
		normal! 6GA
	endif
	if &filetype == 'c'
		call setline(1, "#include<stdio.h>")
		call append(line("."), "")
		call append(line(".")+1, "")
		call append(line(".")+2, "int main(int argv, char* argc[])")
		call append(line(".")+3, "{")
		call append(line(".")+4, "	")
		call append(line(".")+5, "	return 0;")
		call append(line(".")+6, "}")
		normal! 6GA
	endif

	if &filetype == 'python'
		call setline(1, "\#!/usr/bin/python")
		call append(1, "\# encoding: utf-8")
		normal o
		normal o
		normal G
	endif
	
endfunc 

