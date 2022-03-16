"
" Auto Download Plugin
"
if empty(glob('~/.config/nvim/autoload/plug.vim')) 
silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

autocmd VimEnter * PlugInstall --sync | source $MYVIMRC

endif 


" ********
" Global Config
" ********
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set tabstop=4
set shiftwidth=4
syntax enable
set hlsearch
set incsearch
set autoindent
set clipboard+=unnamed
set ruler
set showcmd
set foldenable " 允许折叠 
set foldmethod=manual " 手动折叠 
filetype plugin indent on

set updatetime=100

" **********
" Plugin Config
" **********
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

	" Auto Complete
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	
	" Highlight the symbol and its references when holding the cursor.
	Plug 'RRethy/vim-illuminate'

	" press Enter automatically select the code block
	Plug 'gcmt/wildfire.vim'
	" 更改包裹的内容
	Plug 'tpope/vim-surround'

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

" theme config
let g:airline_theme='light'
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif



" *****
" coc.nvim
" *****
let g:coc_global_extensions = ['coc-json', 
			\ 'coc-vimlsp', 
			\ 'coc-python', 
			\ 'coc-clangd', 
			\ 'coc-sh', 
			\'coc-translator']
set shortmess+=c
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> <LEADER>- <Plug>(coc-diagnostic-prev)
nmap <silent> <LEADER>= <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)





" ***********
" 自动加入代码头
" ***********
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

