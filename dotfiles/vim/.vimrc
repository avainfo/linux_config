" Vim Config File
" Description: Vim config mainly for C
" Author: Ava Info

" Encoding
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8

set nocompatible

" Indent
set smartindent
set cindent
set tabstop=4
set shiftwidth=4
set textwidth=120

" Syntax
set t_Co=256
syntax on
set comments=sl:/*,mb:\ *,elx:\ */

" Shortcuts
nmap <F2> :w<CR>
imap <F2> <ESC>:w<CR>i

set nu rnu

" Ctrl + arrow
if &term =~ 'xterm' || &term =~ 'tmux'
  map <Esc>[1;5D <C-Left>
  map <Esc>[1;5C <C-Right>
  imap <Esc>[1;5D <C-Left>
  imap <Esc>[1;5C <C-Right>
endif
