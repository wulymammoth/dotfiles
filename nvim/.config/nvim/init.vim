source $HOME/.config/nvim/keybinds.vim

" ----- SETTINGS -----

autocmd FocusGained * :checktime " check if buffers changed outside of vim - required for `set autoread` and `set autoindent`
autocmd OptionSet guicursor noautocmd set guicursor=

colorscheme iceyberg

set background=dark
set clipboard+=unnamedplus   " To ALWAYS use the clipboard for ALL operations (instead of registers)
set completeopt=longest,menuone,preview
set copyindent
set cursorline               " Highlight cursor position (row/line)
set encoding=utf-8
set expandtab                " Insert space chars for TAB
set fileencoding=utf-8
set hidden                   " Avoid persisting closed buffers
set ignorecase               " Case-insensitive searches
set inccommand=split         " Shows the effects of a command incrementally, as you type
set incsearch                " Incremental highlighting while searching
set lazyredraw               " Aid in slow redrawing because of 'cursorline'
set linespace=1              " Line spacing
set mouse=a                  " Allow mouse usage in all modes
set noerrorbells             " No beeps
set nohlsearch               " Highlight search (OFF)
set nojoinspaces             " Prevents insertion of two spaces after punctuation on line join (J)
set noswapfile               " Don't make backups before overwriting
set number                   " Always show line numbers
set relativenumber           " Always show line numbers
set ruler                    " Show the line and column number of the cursor position
set shiftround
set shiftwidth=2             " Indentation amount for < and > commands
set showcmd                  " Show (partial) command in status line
set showmatch                " Show matching brackets
set smartcase                " Searching with capital letters
set smartindent
set softtabstop=2
set switchbuf=useopen,usetab " switch to already open buffer
set tabstop=2                " Render tabs using n number of spaces
set tags=tags,./tags,$HOME/tags
set title                    " Set the title of the iTerm tab

call plug#begin('~/.config/nvim/plugged')
  Plug 'airblade/vim-gitgutter'
  Plug 'airblade/vim-rooter'
  Plug 'bling/vim-airline'
  Plug 'cocopon/iceberg.vim'
  Plug 'dhruvasagar/vim-table-mode'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'gkeep/iceberg-dark'
  Plug 'godlygeek/tabular'
  Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'junegunn/goyo.vim'
  Plug 'junegunn/vim-easy-align'
  Plug 'ludovicchabant/vim-gutentags'
  Plug 'mattn/emmet-vim'
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
  Plug 'ntpeters/vim-better-whitespace'
  Plug 'ojroques/vim-oscyank'
  Plug 'prettier/vim-prettier', { 'do': 'npm install', 'for': ['javascript', 'typescript', 'css', 'scss', 'json', 'graphql'] }
  Plug 'scrooloose/nerdcommenter'
  Plug 'sheerun/vim-polyglot'
  Plug 'tomlion/vim-solidity'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-obsession'
  Plug 'vim-test/vim-test'
  Plug 'vimwiki/vimwiki'
call plug#end()

