"
" Auto Download Plugin
"
if empty(glob('~/.config/nvim/autoload/plug.vim')) 
silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

autocmd VimEnter * PlugInstall --sync | source $MYVIMRC

endif 

let g:nvim_plugins_installation_completed=1
if empty(glob($HOME.'/.local/share/nvim/plugged/wildfire.vim/autoload/wildfire.vim'))
	let g:nvim_plugins_installation_completed=0
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
    " Plug 'mg979/vim-xtabline'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }

	" file explore that press ctrl+b
	" Plug 'scrooloose/nerdtree'

	" Auto Complete
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries',  'for': ['go', 'vim-plug'] }
	
	" Highlight the symbol and its references when holding the cursor.
	Plug 'RRethy/vim-illuminate'
    " show color #ffffff
    Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }

    " show indent guides
    Plug 'Yggdroot/indentLine'

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

    Plug 'nvim-lua/plenary.nvim' " ull; complete; entire; absolute; unqualified. All the lua functions
    Plug 'nvim-lua/popup.nvim' " An implementation of the Popup API from vim in Neovim.
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
    Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
    Plug 'nvim-telescope/telescope-live-grep-args.nvim'

	" beautiful catalogue
	Plug 'glepnir/dashboard-nvim'

	" 可以查看文件的历史修改树
	Plug 'mbbill/undotree'

    " snippets
    Plug 'sirver/ultisnips'
    Plug 'honza/vim-snippets'

    " CheatSheet
    " Plug 'liuchengxu/vim-which-key'
    Plug 'folke/which-key.nvim'

    " auto-pair bracket
    Plug 'jiangmiao/auto-pairs'

	" markdown
	Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': 'markdown'}
    Plug 'tpope/vim-markdown'
	Plug 'dhruvasagar/vim-table-mode'
	Plug 'ferrine/md-img-paste.vim'
    " Plug 'mzlogin/vim-markdown-toc', { 'for': ['gitignore', 'markdown', 'vim-plug'] }

    " latex
    " Plug 'lervag/vimtex'

    " codeql
    Plug 'MunifTanjim/nui.nvim' " UI Component Library for Neovim.
    Plug 's1n7ax/nvim-window-picker', { 'tag': 'v1.*' }
    Plug 'pwntester/codeql.nvim'

    " utils plugin
    Plug 'lambdalisue/suda.vim' " do stuff like :sudowrite
    Plug 'akinsho/toggleterm.nvim', { 'tag': 'v2.*' } " open terminal on nvim floating window
    Plug 'rcarriga/nvim-notify' " notify

    " debuger
    " Plug 'puremourning/vimspector', {'do': './install_gadget.py --enable-c --enable-python --enable-go'}

    " Virtual enhance
    Plug 'luochen1990/rainbow'
    Plug 'petertriho/nvim-scrollbar'
    Plug 'kevinhwang91/nvim-hlslens'
    Plug 'lukas-reineke/virt-column.nvim'

call plug#end()


" ==================================================== NERDTree Config
" source ~/.config/nvim/plugins/nerdTree_config.vim

" ==================================================== fzf config
source ~/.config/nvim/plugins/fzf_config.vim

" ==================================================== coc.nvim
source ~/.config/nvim/plugins/coc_config.vim
source ~/.config/nvim/mappings/coc_map.vim

" ==================================================== notify
source ~/.config/nvim/plugins/notify_config.vim


" ==================================================== undotree
source ~/.config/nvim/plugins/undotree_config.vim
source ~/.config/nvim/mappings/undotree_map.vim

" ==================================================== Ultisnipets
source ~/.config/nvim/plugins/ultisnips_config.vim

" ==================================================== auto-pair
source ~/.config/nvim/plugins/auto-pair_config.vim

" ==================================================== latex config
" source ~/.config/nvim/plugins/vimtex_config.vim
" source ~/.config/nvim/mappings/vimtex_map.vim


" ==================================================== markdown config
source ~/.config/nvim/plugins/markdown-preview_config.vim
source ~/.config/nvim/mappings/markdown-preview_map.vim
source ~/.config/nvim/mappings/vim-table-mode_map.vim
source ~/.config/nvim/plugins/md-img-paste_config.vim
source ~/.config/nvim/mappings/md-img-paste_map.vim

" ==================================================== which-key config
" source ~/.config/nvim/plugins/vim-which-key_config.vim
source ~/.config/nvim/plugins/nvim-whichkey_config.vim

" ==================================================== indent-guides config
source ~/.config/nvim/plugins/indentline_config.vim

" ==================================================== debugger
source ~/.config/nvim/plugins/vim-spector_config.vim
source ~/.config/nvim/mappings/vim-spector_map.vim

" ==================================================== ranbow bracket
source ~/.config/nvim/plugins/rainbow_config.vim

" ==================================================== scroll bar and hlslens
source ~/.config/nvim/plugins/nvim-scrollbar_config.vim
source ~/.config/nvim/mappings/nvim-hlslens.vim


" ==================================================== telescope
source ~/.config/nvim/plugins/telescope_config.vim

" ==================================================== terminal toggle
source ~/.config/nvim/plugins/terminaltoggle_config.vim
source ~/.config/nvim/mappings/terminaltoggle_map.vim

" ==================================================== buffer Line config
source ~/.config/nvim/plugins/bufferline_config.vim
source ~/.config/nvim/mappings/bufferline_map.vim

" ==================================================== virt-column.nvim
source ~/.config/nvim/plugins/virt-column_config.vim


" ==================================================== codeQL
source ~/.config/nvim/plugins/codeql_config.vim

