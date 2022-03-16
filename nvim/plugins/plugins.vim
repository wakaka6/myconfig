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
	
	" Highlight the symbol and its references when holding the cursor.
	Plug 'RRethy/vim-illuminate'

	" press Enter automatically select the code block
	Plug 'gcmt/wildfire.vim'
	" 更改包裹的内容
	Plug 'tpope/vim-surround'

	" fuzz search file
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'junegunn/fzf.vim'

	" beautiful catalogue
	Plug 'glepnir/dashboard-nvim'

call plug#end()
