" nnoremap <silent> <f5> :w<CR>:!xelatex %<CR>

set cc=120

inoremap <buffer> ,f <Esc>/<,.><CR>:nohlsearch<CR>"_c4l
inoremap <buffer> ,w <Esc>/ <,.><CR>:nohlsearch<CR>"_c5l
inoremap <buffer> ,b \textbf{}<,.><Esc>F{a
inoremap <buffer> ,i \emph{}<,.><Esc>F{a
" inoremap <buffer> ,m $$ <,.><Esc>F$a
inoremap <buffer> ,l \label{}<,.><Esc>F{a
inoremap <buffer> ,r \ref{}<,.><Esc>F{a


if has("unix") && !has("macunix") && executable("xdotool")
  " Get Vim's window ID for switching focus from Zathura to Vim using xdotool.
  if !exists("g:vim_window_id")
    let g:vim_window_id = system("xdotool getactivewindow")
  endif

  function! s:TexFocusVim() abort
    sleep 200m
    silent execute "!xdotool windowfocus " . expand(g:vim_window_id)
    redraw!
  endfunction

  augroup vimtex_event_focus
    au!
    au User VimtexEventView call s:TexFocusVim()
  augroup END
endif
