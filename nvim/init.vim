" Global Config
source ~/.config/nvim/globals/globals.vim

" Plugin Config
source ~/.config/nvim/plugins/plugins.vim
" NERDTree Config
" source ~/.config/nvim/plugins/nerdTree_config.vim

" fzf config
source ~/.config/nvim/plugins/fzf_config.vim

" theme config
source ~/.config/nvim/themes/airline.vim
source ~/.config/nvim/themes/dashboard_config.vim

" coc.nvim
source ~/.config/nvim/plugins/coc_config.vim

" 自动加入代码头
source ~/.config/nvim/scripts/auto_add_code_head.vim

autocmd BufWritePost $MYVIMRC source $MYVIMRC
