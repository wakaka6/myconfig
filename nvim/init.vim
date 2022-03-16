" ***
" Global Config
" ***
source ~/.config/nvim/globals/globals.vim

" ***
" Maping Config
" ***
source ~/.config/nvim/mappings/mapping.vim

" ***
" Plugin Config
" ***
source ~/.config/nvim/plugins/plugins.vim

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


" markdown config
source ~/.config/nvim/plugins/markdown-preview_config.vim
source ~/.config/nvim/mappings/markdown-preview_map.vim
source ~/.config/nvim/mappings/vim-table-mode_map.vim


" ***
" theme config
" ***
source ~/.config/nvim/themes/airline.vim
" start menu
source ~/.config/nvim/themes/dashboard_config.vim
source ~/.config/nvim/mappings/dashboard_map.vim


" ***
" script congig
" ***
source ~/.config/nvim/scripts/convenience.vim
" 自动加入代码头
source ~/.config/nvim/scripts/auto_add_code_head.vim

autocmd BufWritePost $MYVIMRC source $MYVIMRC
