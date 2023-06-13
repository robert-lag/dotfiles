syntax on

" Set that wrapping only takes place between words and not in the middle of a
" word
set wrap linebreak

" Show a colored column at the specified character
set colorcolumn=80
highlight ColorColumn ctermbg=8

" Expand TABs to spaces
set expandtab

" --- General ---

" Highlight headings in custom color
highlight MkdHeading ctermfg=4 cterm=bold
call matchadd("MkdHeading", "^[#]\\{1,6\}[ ]*\.\\+")

" --- Zettelkasten ---

" Highlight note links in zettelkasten
highlight ZettelkastenNoteLink ctermfg=11
call matchadd("ZettelkastenNoteLink", "\[\[[a-zA-Z0-9]*\]\]")

" Highlight metadata in zettelkasten notes
syntax region ZettelkastenMetadata start="\n\@<!---[ \\t]*$" end="^---[ \\t]*$"
highlight ZettelkastenMetadata ctermfg=7

" --- homebrewery.naturalcrit.com ---

" Highlight colons when they are the only chars in a line
" They stand for spacing
highlight DnDSpacing ctermfg=11
call matchadd("DnDSpacing", "^[:]\\+")
call matchadd("DnDSpacing", "^\\\\page$")
call matchadd("DnDSpacing", "^\\\\column$")

" Highlight notes
highlight DnDNote ctermfg=5
syntax region DndNote start="{{" end="}}"
