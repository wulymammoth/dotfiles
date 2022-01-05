nmap <Leader>/ :Rg<SPACE>
" search for word under visual selection
vnoremap <Leader>/ y:Rg <C-r>=fnameescape(@")<CR><CR>
