" Set that wrapping only takes place between words and not in the middle of a
" word
set wrap linebreak

" Show a colored column at the specified character
set colorcolumn=80
highlight ColorColumn ctermbg=8

" Expand TABs to spaces
set expandtab

" Highlight headings in custom color
highlight MkdHeading ctermfg=4 cterm=bold
call matchadd("MkdHeading", "[#]\\{1,6\}[ ]*\.\\+")

" Highlight note links in zettelkasten
highlight ZettelkastenNoteLink ctermfg=11
call matchadd("ZettelkastenNoteLink", "\[\[[a-zA-Z0-9]*\]\]")

" Highlight metadata in zettelkasten notes
highlight ZettelkastenMetadata ctermfg=7
call matchadd("ZettelkastenMetadata", "^[A-Za-z]\\+: \.\\+")

