" ----- LEADER -----
let g:mapleader="\<Space>"
let g:maplocalleader = ","
let maplocalleader=","
let mapleader="\<Space>"

" ----- file paths -----
" copy file name
nmap <Leader>fn :let @*=expand("%") <bar> :echo @*<CR>
" copy file relative path
nmap <Leader>fy :let @*=expand("%p") <bar> :echo @*<CR>
" copy file full path
nmap <Leader>ffy :let @*=expand("%:p") <bar> :echo @*<CR>

" Shift + J/K moves selected lines down/up in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
