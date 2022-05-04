
let maplocalleader = " "

" Define a custom shortcut to trigger VimtexView
autocmd FileType tex nmap <localleader>v <plug>(vimtex-view)

" Use `<localleader>vc` to trigger continuous compilation...
autocmd FileType tex nmap <C-p> <Plug>(vimtex-compile)
