nmap <C-p> <Plug>MarkdownPreviewToggle
autocmd Filetype markdown inoremap <buffer> ,f <Esc>/<,.><CR>:nohlsearch<CR>"_c4l
autocmd Filetype markdown inoremap <buffer> ,w <Esc>/ <,.><CR>:nohlsearch<CR>"_c5l<CR>
autocmd Filetype markdown inoremap <buffer> ,n ---<Enter><Enter>
autocmd Filetype markdown inoremap <buffer> ,b **** <,.><Esc>F*hi
autocmd Filetype markdown inoremap <buffer> ,s ~~~~ <,.><Esc>F~hi
autocmd Filetype markdown inoremap <buffer> ,i ** <,.><Esc>F*i
autocmd Filetype markdown inoremap <buffer> ,d `` <,.><Esc>F`i
autocmd Filetype markdown inoremap <buffer> ,c ```<Enter>```<Enter><Enter><,.><Esc>3kA
autocmd Filetype markdown inoremap <buffer> ,l - [ ] 
" autocmd Filetype markdown inoremap <buffer> ,p ![](<,.>) <,.><Esc>F[a
" autocmd Filetype markdown inoremap <buffer> ,a [](<,.>) <,.><Esc>F[a
autocmd Filetype markdown inoremap <buffer> ,1 #<Space><Enter><,.><Esc>kA
autocmd Filetype markdown inoremap <buffer> ,2 ##<Space><Enter><,.><Esc>kA
autocmd Filetype markdown inoremap <buffer> ,3 ###<Space><Enter><,.><Esc>kA
autocmd Filetype markdown inoremap <buffer> ,4 ####<Space><Enter><,.><Esc>kA
" autocmd Filetype markdown inoremap <buffer> ,N --------<Enter>
