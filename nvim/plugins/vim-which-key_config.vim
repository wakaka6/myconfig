let g:mapleader = "\<Space>"
" let g:maplocalleader = ','
nnoremap <silent> <leader>  :<c-u>WhichKey '<Space>'<CR>
" nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>

" By default timeoutlen is 1000 ms
set timeoutlen=1000

" ignore maping key
" let g:which_key_map['_'] = { 'name': 'which_key_ignore' }

" Hide statusline when open which_key
autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

let g:which_key_map = {}

let g:which_key_map['f'] = {
      \ 'name' : '+find' ,
      \ 'f' :  [ 'DashboardFindFile', 'Find fuzz file' ]         ,
      \ 'a' :  [ 'DashboardFindWord', 'Find fuzz word' ]         ,
      \ }

call which_key#register('<Space>', "g:which_key_map")
