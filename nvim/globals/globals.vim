" ********
" Global Config
" ********
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set tabstop=4
set shiftwidth=4

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
set foldmethod=manual " 手动折叠 

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



