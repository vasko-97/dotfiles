" Based on various different ideavimrcs. Resources: 
" https://github.com/OptimusCrime/ideavim/blob/main/ideavimrc
" massive collection: https://github.com/JetBrains/ideavim/discussions/303
" https://medium.com/@dbilici/a-practical-ideavim-setup-for-intellij-idea-cf74222e7b45
" https://towardsdatascience.com/the-essential-ideavim-remaps-291d4cd3971b/
"" Base Settings
"" ========================================================

if filereadable(expand("~/.vim/session.vim")) && argc() == 0
  autocmd VimEnter * source ~/.vim/session.vim
  autocmd VimLeavePre * mksession! ~/.vim/session.vim
  set sessionoptions-=options
endif

filetype plugin indent on
syntax on
set relativenumber
set number
set showmode
set showcmd
set ignorecase smartcase
set history=1000
set incsearch
set hlsearch
set title
set hidden
set nocompatible
set scrolloff=5
set clipboard=unnamedplus
" without this the text wraps way too narrowly..
set textwidth=0
if !has('unix')
	" colorschemes don't seem to work the same on Linux and Windows.. default scheme seems fine on Linux, but on Windows I noticed it makes the yaml synax highlighting poor and changing the colorscheme fixes it. 
	colorscheme desert
end

let mapleader = " "
set notimeout

let &t_SI = "\e[6 q"   " Insert mode: beam
let &t_EI = "\e[2 q"   " Normal mode: block
let &t_SR = "\e[4 q"   " Replace mode: underline

"" Key mappings
"" ========================================================

" GNU readline style keymaps for command line editing - temporarily disabled to get used to the default experience
" cnoremap <C-A> <Home>
" cnoremap <C-F> <Right>
" cnoremap <C-B> <Left>
" cnoremap <M-b> <S-Left>
" cnoremap <M-f> <S-Right>
" cnoremap <C-D> <Del>

" center cursor after screen movement
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv
vnoremap n nzzzv
vnoremap N Nzzzv

" After block yank and paste, move cursor to the end of operated text and don't override register
" vnoremap p "_dp`]
nnoremap p p`]

" speed up scrolling
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" move cursor to end of selection after yanking it
vnoremap y ygv<Esc>`>
" Y should yank until the end of line, for consistency with C, D
nnoremap Y y$

" v-todo: temporarily disabling register remaps below until I get used to the default register experience.
" v-todo: do something reasonable: https://chatgpt.com/c/697266bf-72fc-8329-9410-8e9caf22d57c
" Make X an operator that removes without placing text in the default registry
" nmap X "_d
" nmap XX "_dd
" vmap X "_d
" vmap x "_d
" don't yank to default register when changing something
" nnoremap c "xc
" xnoremap c "xc
nnoremap x "_x

" make R actually useful
nmap R ciw

" Reselect last-pasted text
" use cases: format, indent, comment
nnoremap gp `[v`]

" Easy visual indentation
vnoremap < <gv
vnoremap > >gv

" set undo breakpoints when deleting text in insert mode such that the deleted text can easily be recovered.
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

" https://github.com/stoeffel/.dotfiles/blob/master/vim/visual-at.vim
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>
function! ExecuteMacroOverVisualRange()
	  echo "@".getcmdline()
	    execute ":'<,'>normal @".nr2char(getchar())
endfunction

" a macro to easily turn "one\ntwo\nthreee" into "'one','two','three" for use in SQL WHERE clauses
let @q="_}kI'€ý5$}k$A',€ý5V}kJ$x"
