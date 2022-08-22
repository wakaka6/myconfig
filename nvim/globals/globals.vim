" ********
" Global Config
" ********
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set tabstop=4
set shiftwidth=4
set expandtab  " using space relace tab
set termguicolors


syntax enable
exec "nohlsearch"
set hlsearch
set incsearch
set cursorline " highlight current cursor line

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

" Always show tabs
set showtabline=2
" don't show like INSERT more something mode
set noshowmode
" auto search highlight

" 保持屏幕上下总显示5行
set scrolloff=5

" 在命令模式用tab提供选择菜单
set wildmenu

" add suport for plugin
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on

" set the .tex is of type latex filetype , not plaintext or context
let g:tex_flavor = "latex"

let g:vimsyn_embed = 'l'

" === 
" === 输入法配置
" ===
" 退出插入模式时禁用输入法
autocmd InsertLeave * :silent !fcitx5-remote -c 
" 创建 Buf 时禁用输入法
autocmd BufCreate *  :silent !fcitx5-remote -c 
" 进入 Buf 时禁用输入法
autocmd BufEnter *  :silent !fcitx5-remote -c 
" 离开 Buf 时禁用输入法
autocmd BufLeave *  :silent !fcitx5-remote -c 


