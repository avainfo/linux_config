" Vim Config File
" Description: Vim config mainly for C
" Author: Ava Info

" Encoding
set enc=utf-8
set fenc=utf-8
if exists('&termencoding')
  set termencoding=utf-8
endif

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

function! NorminetteCheck() abort
  " Exécute norminette sur le fichier courant
  let l:out = systemlist('norminette ' . expand('%'))

  " Prépare la liste quickfix
  let l:qf = []
  for l:line in l:out
    call add(l:qf, {
          \ 'filename': expand('%'),
          \ 'lnum': 1,
          \ 'col': 1,
          \ 'text': l:line,
          \ 'type': 'E'
          \ })
  endfor

  " Remplace le contenu du quickfix par notre liste
  call setqflist(l:qf, 'r')

  " Ouvre la quickfix window si erreurs
  if len(l:qf) > 0
    copen
  else
    cclose | echo "Norminette OK"
  endif
endfunction

nnoremap <leader>n :call NorminetteCheck()<CR>

