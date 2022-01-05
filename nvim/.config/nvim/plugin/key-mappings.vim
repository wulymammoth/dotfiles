" ----- LEADER -----
let g:mapleader="\<Space>"
let g:maplocalleader = ","
let localleader=","
let mapleader="\<Space>"

" ----- file paths -----
" copy file name
nmap <Leader>fn :let @*=expand("%") <bar> :echo @*<CR>
" copy file relative path
nmap <Leader>fy :let @*=expand("%p") <bar> :echo @*<CR>
" copy file full path
nmap <Leader>ffy :let @*=expand("%:p") <bar> :echo @*<CR>
