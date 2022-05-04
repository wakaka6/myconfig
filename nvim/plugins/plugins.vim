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
    Plug 'sirver/ultisnips'
    Plug 'honza/vim-snippets'

    " CheatSheet
    Plug 'liuchengxu/vim-which-key'


	" markdown
	Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': 'markdown'}
	Plug 'dhruvasagar/vim-table-mode'
	Plug 'ferrine/md-img-paste.vim'

    " latex
    Plug 'lervag/vimtex'


    " utils plugin
    Plug 'lambdalisue/suda.vim' " do stuff like :sudowrite

    " debuger
    Plug 'puremourning/vimspector', {'do': './install_gadget.py --enable-c --enable-python --enable-go'}

call plug#end()


" NERDTree Config
" source ~/.config/nvim/plugins/nerdTree_config.vim

" fzf config
source ~/.config/nvim/plugins/fzf_config.vim

" coc.nvim
source ~/.config/nvim/plugins/coc_config.vim
source ~/.config/nvim/mappings/coc_map.vim

" undotree
source ~/.config/nvim/plugins/undotree_config.vim
source ~/.config/nvim/mappings/undotree_map.vim

" Ultisnipets
source ~/.config/nvim/plugins/ultisnips_config.vim

" auto-pair
source ~/.config/nvim/plugins/auto-pair_config.vim

" latex config
source ~/.config/nvim/plugins/vimtex_config.vim
source ~/.config/nvim/mappings/vimtex_map.vim


" markdown config
source ~/.config/nvim/plugins/markdown-preview_config.vim
source ~/.config/nvim/mappings/markdown-preview_map.vim
source ~/.config/nvim/mappings/vim-table-mode_map.vim
source ~/.config/nvim/plugins/md-img-paste_config.vim
source ~/.config/nvim/mappings/md-img-paste_map.vim

" which-key config
source ~/.config/nvim/plugins/vim-which-key_config.vim

" indent-guides config
" source ~/.config/nvim/plugins/vim-indent-guides_config.vim

" debugger
source ~/.config/nvim/plugins/vim-spector_config.vim
source ~/.config/nvim/mappings/vim-spector_map.vim
