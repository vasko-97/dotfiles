" Based on various different ideavimrcs. Resources: 
" https://github.com/OptimusCrime/ideavim/blob/main/ideavimrc
" massive collection: https://github.com/JetBrains/ideavim/discussions/303
" https://medium.com/@dbilici/a-practical-ideavim-setup-for-intellij-idea-cf74222e7b45
" https://towardsdatascience.com/the-essential-ideavim-remaps-291d4cd3971b/
"" Base Settings
"" ========================================================


" Save session automatically on exit
autocmd VimLeavePre * mksession! ~/.vim/session.vim

" Load session automatically on start if it exists
if filereadable(expand("~/.vim/session.vim"))
  autocmd VimEnter * source ~/.vim/session.vim
endif

set relativenumber
set number
set showmode
set showcmd
set ignorecase smartcase
set history=1000
set incsearch
set hlsearch
set title
set scrolloff=5
" set visualbell
set virtualedit=onemore

let mapleader = " "
set notimeout

if &term =~ "xterm"
  let &t_SI = "\e[6 q"   " Insert mode: beam
  let &t_EI = "\e[2 q"   " Normal mode: block
  let &t_SR = "\e[4 q"   " Replace mode: underline
endif

"" Key mappings
"" ========================================================

" center cursor after screen movement
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap H Hzz
nnoremap M Mzz
nnoremap L Lzz
nnoremap n nzzzv
nnoremap N Nzzzv
vnoremap n nzzzv
vnoremap N Nzzzv

" After block yank and paste, move cursor to the end of operated text and don't override register
vnoremap p "_dP`]
nnoremap p p`]

" move cursor to end of selection after yanking it
vnoremap y ygv<Esc>`]
" Y should yank until the end of line, for consistency with C, D
nnoremap Y y$

" Yank and paste from OS clipboard
nnoremap ,y "+y
vnoremap ,y "+y
nnoremap ,yy "+yy
nnoremap ,p "+p
vnoremap ,p "+p

" have x (removes single character) not go into the default registry
nnoremap x "_x
" Make X an operator that removes without placing text in the default registry
nmap X "_d
nmap XX "_dd
vmap X "_d
vmap x "_d

" don't yank to default register when changing something
nnoremap c "xc
xnoremap c "xc

" Reselect last-pasted text
" use cases: format, indent, comment
nnoremap gp `[v`]

inoremap jk <Esc>
inoremap kj <Esc>

" Easy visual indentation
vnoremap < <gv
vnoremap > >gv

" Execute macro saved in 'q' register
nnoremap qj @q
