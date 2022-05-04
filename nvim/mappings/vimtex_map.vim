
let maplocalleader = " "

" Define a custom shortcut to trigger VimtexView
autocmd FileType tex nmap <localleader>v <plug>(vimtex-view)

" Use `<localleader>vc` to trigger continuous compilation...
autocmd FileType tex nmap <C-p> <Plug>(vimtex-compile)

" Use `dsm` to delete surrounding math (replacing the default shorcut `ds$`)
nmap dsm <Plug>(vimtex-env-delete-math)

" Use `tsm` to toggle surrounding math (replacing the default shorcut `ts$`)
nmap tsm <Plug>(vimtex-env-toggle-math)








