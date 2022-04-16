"
" Auto Download Plugin
"
if empty(glob('~/.config/nvim/autoload/plug.vim')) 
silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

autocmd VimEnter * PlugInstall --sync | source $MYVIMRC

endif 

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
	Plug 'ryanoasis/vim-devicons'

	" file explore that press ctrl+b
	" Plug 'scrooloose/nerdtree'

	" Auto Complete
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
	
	" Highlight the symbol and its references when holding the cursor.
	Plug 'RRethy/vim-illuminate'

    " show indent guides
    " Plug 'nathanaelkane/vim-indent-guides'

	" press Enter automatically select the code block
	Plug 'gcmt/wildfire.vim'

    " multi-cursor
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}

	" 更改包裹的内容
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-repeat'

	" fuzz search file
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'junegunn/fzf.vim'

	" beautiful catalogue
	Plug 'glepnir/dashboard-nvim'

	" 可以查看文件的历史修改树
	Plug 'mbbill/undotree'

    " snippets
    Plug 'honza/vim-snippets'

    " CheatSheet
    Plug 'liuchengxu/vim-which-key'


	" markdown
	Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': 'markdown'}
	Plug 'dhruvasagar/vim-table-mode'
	Plug 'ferrine/md-img-paste.vim'

    " utils plugin
    Plug 'lambdalisue/suda.vim' " do stuff like :sudowrite

call plug#end()
