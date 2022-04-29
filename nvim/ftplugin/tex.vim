nnoremap <silent> <f5> :w<CR>:!xelatex %<CR>

inoremap <buffer> ,f <Esc>/<,.><CR>:nohlsearch<CR>"_c4l
inoremap <buffer> ,w <Esc>/ <,.><CR>:nohlsearch<CR>"_c5l
inoremap <buffer> ,b \textbf{}<,.><Esc>F{a
inoremap <buffer> ,i \emph{}<,.><Esc>F{a
inoremap <buffer> ,m $$ <,.><Esc>F$a
inoremap <buffer> ,l \label{}<,.><Esc>F{a
inoremap <buffer> ,r \ref{}<,.><Esc>F{a

