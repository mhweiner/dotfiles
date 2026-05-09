" dotfiles/vimrc — sensible defaults (Vim 8+). Sourced from ~/.vimrc by install.sh (never overwrites ~/.vimrc).

set nocompatible
syntax enable
filetype plugin indent on

set number
set incsearch hlsearch
set ignorecase smartcase
set autoread
set hidden
set backspace=indent,eol,start
set encoding=utf-8

set tabstop=4 shiftwidth=4 expandtab
set autoindent smartindent

set wildmenu wildmode=longest:full,full
set laststatus=2 ruler showcmd
set clipboard=unnamed

set undofile
set undodir=~/.vim/undo
silent! call mkdir(expand('~/.vim/undo'), 'p', 0700)

colorscheme default
if has('termguicolors') && &t_Co >= 256
  set termguicolors
endif

nnoremap <leader><space> :nohlsearch<CR>
