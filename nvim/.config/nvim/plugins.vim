call plug#begin('~/.config/nvim/plugged')
  Plug 'airblade/vim-gitgutter'
  Plug 'airblade/vim-rooter'
  Plug 'bling/vim-airline'
  Plug 'cocopon/iceberg.vim'
  Plug 'dhruvasagar/vim-table-mode'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'gkeep/iceberg-dark'
  Plug 'godlygeek/tabular'
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'junegunn/goyo.vim'
  Plug 'junegunn/vim-easy-align'
  Plug 'ludovicchabant/vim-gutentags'
  Plug 'mattn/emmet-vim'
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
  Plug 'ntpeters/vim-better-whitespace'
  Plug 'prettier/vim-prettier', { 'do': 'npm install', 'for': ['javascript', 'typescript', 'css', 'scss', 'json', 'graphql'] }
  Plug 'scrooloose/nerdcommenter'
  Plug 'sheerun/vim-polyglot'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-obsession'
  Plug 'vim-test/vim-test'
  Plug 'vimwiki/vimwiki'
call plug#end()

" ----- easy-align -----
" start interactive easyalign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" start interactive easyalign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" ----- fzf.vim -----
let $FZF_DEFAULT_COMMAND = 'rg --files' " use ripgrep as the default searcher

function! s:buflist()
  redir => ls
  silent ls
  redir END
  return split(ls, '\n')
endfunction

function! s:bufopen(e)
  execute 'buffer' matchstr(a:e, '^[ 0-9]*')
endfunction

" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

nmap <Leader>pf :FZF<CR>

nnoremap <silent> <Leader><Enter> :call fzf#run({
\   'source':  reverse(<sid>buflist()),
\   'sink':    function('<sid>bufopen'),
\   'options': '+m',
\   'down':    len(<sid>buflist()) + 2
\ })<CR>

" ----- goyo -----
let g:goyo_height = 100
let g:goyo_linenr = 1
let g:goyo_width  = 120

" ----- ripgrep -----
nmap <Leader>/ :Rg<SPACE>
" search for word under visual selection
vnoremap <Leader>/ y:Rg <C-r>=fnameescape(@")<CR><CR>

" ----- vim-airline -----
let g:airline#extensions#tabline#enabled      = 1
let g:airline#extensions#tabline#formatter    = 'short_path'
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#left_sep     = ' '
let g:airline_powerline_fonts                 = 1
let g:airline_theme='iceberg'

" ----- vim-better-whitespace -----
let g:better_whitespace_enabled             = 0
let g:current_line_whitespace_disabled_hard = 1
let g:strip_whitespace_confirm              = 0
let g:strip_whitespace_on_save              = 1

" ----- vim-polyglot -----
let g:vim_markdown_new_list_item_indent = 2 " Markdown default indentation

" ----- vim-prettier -----
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.scss,*.json,*.graphql,*.vue PrettierAsync
let g:prettier#autoformat             = 0
let g:prettier#config#bracket_spacing = 'true'
let g:prettier#config#print_width     = 120
let g:prettier#exec_cmd_async         = 1

" ----- vim-test -----
nmap <silent> t<C-n> :TestNearest<CR>
nmap <silent> t<C-f> :TestFile<CR>
nmap <silent> t<C-s> :TestSuite<CR>
nmap <silent> t<C-l> :TestLast<CR>
nmap <silent> t<C-g> :TestVisit<CR>

" ----- vim-table-mode -----
function! s:isAtStartOfLine(mapping)
  let text_before_cursor = getline('.')[0 : col('.')-1]
  let mapping_pattern = '\V' . escape(a:mapping, '\')
  let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
  return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction

inoreabbrev <expr> <bar><bar>
          \ <SID>isAtStartOfLine('\|\|') ?
          \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
inoreabbrev <expr> __
          \ <SID>isAtStartOfLine('__') ?
          \ '<c-o>:silent! TableModeDisable<cr>' : '__'

" ----- vimwiki -----
let g:vimwiki_ext2syntax = {}
