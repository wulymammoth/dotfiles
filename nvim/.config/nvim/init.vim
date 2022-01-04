" ------ PLUGINS -----
call plug#begin('~/.config/nvim/plugged')
  Plug 'L3MON4D3/LuaSnip'
  Plug 'airblade/vim-rooter'
  Plug 'cocopon/iceberg.vim' " theme
  Plug 'dhruvasagar/vim-table-mode'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'folke/todo-comments.nvim'
  Plug 'folke/trouble.nvim'
  Plug 'folke/twilight.nvim' " dim inactive segments of code
  Plug 'folke/which-key.nvim' "pop-up with available key-bindings
  Plug 'folke/zen-mode.nvim' " distraction-free coding
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/nvim-cmp' " auto-completion engine
  Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }
  Plug 'junegunn/fzf' " general-purpose command-line fuzzy-finder
  Plug 'junegunn/vim-easy-align'
  Plug 'kosayoda/nvim-lightbulb' " display lightbulb icon when a code-action is available
  Plug 'kyazdani42/nvim-web-devicons'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'ludovicchabant/vim-gutentags' "tag file management in vim
  Plug 'lukas-reineke/indent-blankline.nvim' " indentation guides
  Plug 'mattn/emmet-vim' " abbreviation expansion (webdev)
  Plug 'mfussenegger/nvim-dap'
  Plug 'mickael-menu/zk-nvim' " plugin for zk (Zettelkasten)
  Plug 'neovim/nvim-lspconfig' " common configs for nvim's LSP client
  Plug 'ntpeters/vim-better-whitespace' " highlight and strip whitespace
  Plug 'numToStr/Comment.nvim'
  Plug 'nvim-lua/plenary.nvim' " common Lua functions (dependency for many nvim plugins)
  Plug 'nvim-lualine/lualine.nvim' " status line
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' } " C port of fzf
  Plug 'nvim-telescope/telescope.nvim' " list fuzzy-finder
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " nvim treesitter interface // parse-generation and incremental parsing library
  Plug 'nvim-treesitter/nvim-treesitter-refactor' " clutch plugin providing clutch things like renaming all variables of the same name and type (powered by treesitter)
  Plug 'ojroques/vim-oscyank' " a vim / neovim plugin to copy text to the system clipboard from anywhere using the ansi osc52 sequence
  Plug 'onsails/lspkind-nvim' " vsc-like pictograms in nvim
  Plug 'prettier/vim-prettier', { 'do': 'npm install', 'for': ['javascript', 'typescript', 'css', 'scss', 'json', 'graphql'] }
  Plug 'saadparwaiz1/cmp_luasnip'
  Plug 'simrat39/rust-tools.nvim'
  Plug 'thesis/vim-solidity' " needed until treesitter parser exists
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-obsession' " coupled with tmux-resurrect for saving and restoring vim sessions
  Plug 'vim-test/vim-test'
  Plug 'williamboman/nvim-lsp-installer' " manage LSP servers
call plug#end()

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
set foldexpr=nvim_treesitter#foldexpr()
set foldmethod=expr
set hidden                   " Avoid persisting closed buffers
set ignorecase               " Case-insensitive searches
set inccommand=split         " Shows the effects of a command incrementally, as you type
set incsearch                " Incremental highlighting while searching
set lazyredraw               " Aid in slow redrawing because of 'cursorline'
set linespace=1              " Line spacing
set mouse=a                  " Allow mouse usage in all modes
set noerrorbells             " No beeps
set nofoldenable             " disable code folding by default
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
set splitright               " open new splits to the right (instead of the left [default])
set switchbuf=useopen,usetab " switch to already open buffer
set tabstop=2                " Render tabs using n number of spaces
set tags=tags,./tags,$HOME/tags
set termguicolors            " true color
set title                    " Set the title of the iTerm tab
set updatetime=100
