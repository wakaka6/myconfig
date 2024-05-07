" ***********
" 自动加入代码头
" ***********
autocmd BufNewFile *.cpp,*.[ch],*.sh,*.java,*.py exec ":call AutoSetCodeTitle()" 
func AutoSetCodeTitle() 
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
		call append(line(".")+4, "  ")
		call append(line(".")+5, "  return 0;")
		call append(line(".")+6, "}")
		normal! 6GA
	endif
	if &filetype == 'c'
		call setline(1, "#include <stdio.h>")
		call append(line(".")+0, "#include <stdlib.h>")
		call append(line(".")+1, "#include <string.h>")
		call append(line(".")+2, "#include <unistd.h>")
		call append(line(".")+3, "")
		call append(line(".")+4, "")
		call append(line(".")+5, "int main(int argc, char* argv[])")
		call append(line(".")+6, "{")
		call append(line(".")+7, "  ")
		call append(line(".")+8, "  return 0;")
		call append(line(".")+9, "}")
		normal! 9GA
	endif

	if &filetype == 'python'
		call setline(1, "\#!/usr/bin/env python")
		call append(line(".")+0, "\# encoding: utf-8")
		normal G
		normal o
		normal o
	endif

endfunc 

