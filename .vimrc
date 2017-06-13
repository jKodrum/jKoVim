" {***** Basic Setting *****
" :set all		" see current setting
" :so %<cr>		" reload current file.
" let &termencoding=&encoding
se fencs=utf-8,big5,gbk,latin1,unicode,ansi
" ucs-bom: unicode little endian
" ucs-bom == utf-16le
se fenc=utf-8
" se filetype               " se ft
" se termencoding=utf8      " se tenc
" se encoding=prc           " se enc
" se fileformat=unix        " se ff=unix
" se fileformats=unix,dos   " se ffs=unix,dos
sy on
se nu                       " se number
se ts=4                     " se tabstop=4
se sw=4                     " se shiftwidth=4
" se wrap                   " automatic word wrapping
se et                       " expandtab, tab substituted by spaces
" se noet
se hls                      " hlsearch
se cul                      " cursorline
se ls=2                     " laststatus 0:never 1:show if multi-window 2:always
se t_Co=256                 " if your terminal supports 256 colours
" se cin                    " cindent
"***indent***
" a. autoindent (ai): copy the indentation from the previous line
" b. smartindent (si): works for C-like file
" c. cindent (cin): more customizable then smartindent
se diffopt=vertical         " use diffs with vertical  splits
se fo+=r                    " formatoption r:comment leader after
" se mouse=a
" se mouse=""
se fdm=syntax               " foldmethod=syntax
se fdl=20                   " foldlevel=20
filetype indent on          " indent for php and html
autocmd FileType c setl sw=4 ts=4           " setlocal
autocmd FileType cpp setl sw=4 ts=4
autocmd FileType conf setl sw=4 ts=4
autocmd FileType eruby setl sw=2 ts=2
autocmd FileType html setl sw=2 ts=2
autocmd FileType java setl sw=4 ts=4
autocmd FileType javascript setl sw=4 ts=4
autocmd FileType python setl sw=4 ts=4
autocmd FileType ruby setl sw=2 ts=2
autocmd FileType yaml setl sw=2 ts=2
" }***** Basic Setting *****


" {***** NeoBundle *****
" Using Shougo's NeoBundle.
" ref: https://github.com/Shougo/neobundle.vim
" $ curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
" :NeoBundleList<cr>
if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=$HOME/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('$HOME/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Add or remove your Bundles here:
NeoBundle 'flazz/vim-colorschemes'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'Tagbar'
"NeoBundle 'vim-scripts/cscope.vim'
"NeoBundle 'simplyzhao/cscope_maps.vim'
"NeoBundle 'vim-scripts/fakeclip'

" You can specify revision/branch/tag.
" NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
" }***** NeoBundle *****


" {***** Mapping *****
" [normal|insert|visual] non-recursive map
" an exclamation mark '!' toggles the value
" a question mark '?' show the value
nnoremap <F2> :se paste! paste?<cr>
nnoremap <F4> :echo expand('%:p')<cr>
nnoremap <F5> :so $MYVIMRC<cr>
nnoremap <F6> :tabe $MYVIMRC<cr>
"nnoremap <F7> :%!xxd -r<cr>
nnoremap <F8> :NERDTreeToggle<cr>
" let g:NERDTreeWinPos = "right"
nnoremap <F9> :TagbarToggle<cr>
"nnoremap <F10> :%!xxd<cr>
nnoremap <C-H> :tabN<cr>
nnoremap <C-L> :tabn<cr>
nnoremap <C-K> <c-w><
nnoremap <C-J> <c-w>>
nnoremap <C-T> :tabe 
nnoremap <C-M> :w<cr>
nnoremap <C-P> :cprev<cr>
nnoremap <C-N> :cnext<cr>
nnoremap [q :cfirst<cr>
nnoremap ]q :clast<cr>
" CTRL-SLASH is registered as <c-_>
nnoremap <c-_> *:vim /<c-r>// ##<cr>
vnoremap // y/<c-r>"<cr>
vnoremap /. y/\<<c-r>"\><cr>:vim /\<<c-r>\>/ ##<cr>
vnoremap /, y/<c-r>"<cr>:vim /<c-r> /##<cr>
cnoremap <c-_> args `find . -type f -not -path './.*/*' -name '*'   
" Commands Notes
" :tabo<cr>         " tabe only
" :tabc<cr>         " tabe close
" :m+<cr>
" :m-2<cr>
" <C-W>+
" <C-W>-
" :cw<cr>
" :clist<cr>
" :cc {line_number}<cr>
" }***** Mapping *****


" {***** ColorScheme *****
colorscheme wombat256
" }***** ColorScheme *****
