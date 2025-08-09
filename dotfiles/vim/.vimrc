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
set tabstop=4
set shiftwidth=4
set textwidth=120

" Syntax
set t_Co=256
syntax on
set showmatch
set comments=sl:/*,mb:\ *,elx:\ */

" Shortcuts
nmap <F2> :w<CR>
imap <F2> <ESC>:w<CR>i

set nu rnu
