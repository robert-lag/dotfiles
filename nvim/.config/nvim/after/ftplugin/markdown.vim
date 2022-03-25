syntax match ZettelkastenNoteLink "\v\[\[[a-zA-Z0-9]+\]\]"
highlight ZettelkastenNoteLink ctermfg=Yellow

" Set that wrapping only takes place between words and not in the middle of a
" word
set wrap linebreak

" Show a colored column at the specified character
set colorcolumn=80
highlight ColorColumn ctermbg=8

" Expand TABs to spaces
set expandtab
