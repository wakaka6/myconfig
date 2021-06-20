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

" 新建.c,.h,.sh,.java, .py文件，自动插入文件头 
autocmd BufNewFile *.cpp,*.[ch],*.sh,*.java,*.py exec ":call AutoSetTitle()" 
" 定义函数AutoSetTitle，自动插入文件头 
func AutoSetTitle() 
	" 如果文件类型为.sh文件 
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

