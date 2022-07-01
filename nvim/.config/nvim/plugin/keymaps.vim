" ----- LEADER -----
let g:mapleader="\<Space>"
let g:maplocalleader = ","
let maplocalleader=","
let mapleader="\<Space>"

" ----- nvim-dap ----
nmap <silent> <Leader>b :lua require('dap').toggle_breakpoint()<CR>
nmap <silent> <Leader>B :lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nmap <silent> <Leader>dr :lua require('dap').repl.open()<CR>

nnoremap <silent> <Leader>dn :lua require('dap-python').test_method()<CR>
nnoremap <silent> <Leader>df :lua require('dap-python').test_class()<CR>
vnoremap <silent> <Leader>ds <ESC>:lua require('dap-python').debug_selection()<CR>

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

" <C-c> issue with todo-comment plugin
" (https://github.com/folke/todo-comments.nvim/issues/73)
inoremap <C-c> <Esc>
