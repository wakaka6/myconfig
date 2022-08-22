au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" no highlight current line when terminal
au TermLeave * set cursorline
au TermEnter * set nocursorline
