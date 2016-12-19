" --------------------------------------------------------------------------------
" Script name  : vimrc
" Author       : Dave Rix (dave@analysisbydesign.co.uk)
" Created      : 2015-01-01
" Description  : Some useful vim configuration settings
"              : symlink this file to ~/.vimrc
" History      :
"  2015-01-01  : DAR - Initial script
" -------------------------------------------------------------------------------- 

" Make cursors work as expected
set nocompatible
set term=ansi

" Ignore case when searching unless there is an upper case in the search string
set ignorecase 
set smartcase

" Set the window title when editing a file?
set title

" See more of the file as you approach the end
set scrolloff=3

" Add a ruler to the footer
set ruler

" Intuitive backspacing in insert mode
set backspace=indent,eol,start
 
" And turn on the visual bell
set visualbell

" Set the tabstop
set tabstop=4
set shiftwidth=4
set softtabstop=0 expandtab smarttab

