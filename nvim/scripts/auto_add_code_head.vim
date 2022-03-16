" ***********
" 自动加入代码头
" ***********
autocmd BufNewFile *.cpp,*.[ch],*.sh,*.java,*.py exec ":call AutoSetCodeTitle()" 
func AutoSetCodeTitle() 
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
