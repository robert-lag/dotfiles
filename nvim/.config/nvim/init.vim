"             _
"  _ ____   _(_)_ __ ___
" | '_ \ \ / / | '_ ` _ \
" | | | \ V /| | | | | | |
" |_| |_|\_/ |_|_| |_| |_|
"

" --------------------------------------------------------------------------
" General {{{1
" --------------------------------------------------------------------------

" Disable compatibility with Vi to enable useful Vim functionality
set nocompatible

" Dark background (to be able to use the dark variant of a colorscheme)
set background=dark

" 'Q' in normal mode enters Ex mode. You almost never want this
"nmap Q <Nop>

" Set the update time (in ms) which determines the delay of e.g. the writing
" of the swap file or gitgutter markers
set updatetime=300

" Persistent undo
set undofile
set undodir=$HOME/.local/share/nvim/undodir

" Always use system clipboard
set clipboard+=unnamedplus

" Enable autocompletion
set wildmode=longest,list,full

" Splits open at the bottom and right instead of at the top
set splitbelow splitright

" }}}1

" --------------------------------------------------------------------------
" Environment {{{1
" --------------------------------------------------------------------------

" Don't show which mode you're currently in (is handled by statusbar plugin)
set noshowmode

" Show current line number and relative line numbers to the current line
set number
set relativenumber

" Always show the status line at the bottom, even if you only have one window
" open.
set laststatus=2

" Make it possible to backspace over anything
set backspace=indent,eol,start

" Always hide a buffer (even if it has unsaved changes)
set hidden

" Disable audible bell
set noerrorbells visualbell t_vb=

" Enable mouse support
set mouse+=a

" Set offset between cursor and the upper and lower borders of the display
set scrolloff=5

" Make search case-insensitive when all chars in a string are lowercase.
" Otherwise let the search be case-sensitive.
set ignorecase
set smartcase

" Enable automatic indenting
set smartindent
set autoindent

" Enable searching as you type, rather than waiting till yo press enter
set incsearch

" Always show the signcolumn
set signcolumn=yes

" Set the width of a tab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Strip trailing whitespace on save
function! <SID>StripTrailingWhitespaces()
    if !&binary && &filetype != 'diff'
        let l:save = winsaveview()
        keeppatterns %s/\s\+$//e
        call winrestview(l:save)
    endif
endfun
autocmd FileType c,cpp,java,php,ruby,python,rust,sh,zsh,conf autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" }}}1

" --------------------------------------------------------------------------
" Folding {{{1
" --------------------------------------------------------------------------

" Enable recognition of folds based on markers
set foldmethod=marker

" Open all folds when opening a file
"set foldlevelstart=20

" Make folds persistent across sessions
autocmd BufWinLeave * mkview
autocmd BufWinEnter * silent! loadview

" }}}1

" --------------------------------------------------------------------------
" Colors {{{1
" --------------------------------------------------------------------------
highlight! link SignColumn Background

" Hide tilde ('~') symbols at end of files
highlight NonText ctermfg=0 ctermbg=0

" Popup menu (tooltip) colors
highlight Pmenu ctermfg=15 ctermbg=8
highlight PmenuSel ctermfg=15 ctermbg=6
highlight PmenuSbar ctermfg=15 ctermbg=8
highlight PmenuThumb ctermfg=15 ctermbg=15

" Color of folds
highlight Folded ctermfg=15 ctermbg=8

" Color of concealed passages (like dollar signs at the beginning
" and end of a formula in latex)
highlight Conceal ctermfg=11 ctermbg=8

" Color of misspelled words
highlight SpellBad ctermfg=15 ctermbg=9

" Color of line numbers
highlight LineNr ctermfg=11 ctermbg=0
highlight LineNrAbove ctermfg=240 ctermbg=0
highlight LineNrBelow ctermfg=240 ctermbg=0

" Show trailing whitespace
highlight ExtraWhitespace ctermfg=15 ctermbg=8
autocmd ColorScheme * highlight ExtraWhitespace
autocmd BufEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhiteSpace /\s\+$/

" Diff colors
highlight DiffDelete cterm=bold ctermfg=0 ctermbg=5
highlight DiffText cterm=bold ctermfg=0 ctermbg=3
highlight DiffAdd cterm=none ctermfg=0 ctermbg=6
highlight DiffChange cterm=none ctermfg=0 ctermbg=4

" }}}1

" --------------------------------------------------------------------------
" Key mappings {{{1
" --------------------------------------------------------------------------

" Set leader character
let mapleader = ","

" Make it possible to clear the highlighting of words until the next search
" by pressing <esc>
" Causes bugs!!!
nnoremap <esc> :noh<return><esc>:<esc>

" Shortcuts for split navigation, saving a keypress

" Toggle spellchecking
noremap <leader>c :setlocal spell! spelllang=en_us,de<CR>

" Correct last spelling mistake
nnoremap <leader>d <c-g>u<Esc>[s1z=`]a<c-g>u

" Programming snippets
nnoremap <Space><Space> <Esc>/<++><CR>"_c4l
source $XDG_CONFIG_HOME/nvim/code-snippets/rust.vim
source $XDG_CONFIG_HOME/nvim/code-snippets/latex.vim

" Zettelkasten script shortcuts
noremap <leader>bh :silent !dmenu-zettelkasten-history-viewer -o<cr>
noremap <leader>bl :silent !dmenu-zettelkasten-history-viewer -l<cr>
noremap <leader>bo :silent !cat<Space>"%"<Space>\|<Space>dmenu-zettelkasten-link-handler<Space>-o<cr>

" Move between changes
noremap <leader>n ]c
noremap <leader>N [c

noremap <n ]c
noremap <N [c

" Move between windows
noremap <leader>h <C-w>h
noremap <leader>j <C-w>j
noremap <leader>k <C-w>k
noremap <leader>l <C-w>l
noremap <leader>w <C-w><C-w>

noremap <h <C-w>h
noremap <j <C-w>j
noremap <k <C-w>k
noremap <l <C-w>l
noremap <w <C-w><C-w>

" noremap <C-h> <C-w>h
" noremap <C-j> <C-w>j
" noremap <C-k> <C-w>k
" noremap <C-l> <C-w>l

" This remapping is needed to ensure that nvim doesn't wait
" for further input after the second '<' is typed
noremap << <<

" }}}1

" --------------------------------------------------------------------------
" Filetypes {{{1
" --------------------------------------------------------------------------

" Enable syntax highlighting
syntax on

" Enable filetype plugins
filetype plugin indent on

" Set the filetype based on the file's extension, but only if 'filetype' has
" not already been set
augroup auto_filetype
    " If the file has the extension or is called 'xesources'
    autocmd BufRead,BufNewFile *xresources setfiletype xdefaults

    autocmd BufRead,BufNewFile *.conf setfiletype conf
    autocmd BufRead,BufNewFile config setfiletype conf
augroup END

" Run xrdb whenever Xresources is updated
autocmd BufWritePost Xresources,xresources !xrdb %

" Save file as sudo
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" }}}1

" --------------------------------------------------------------------------
" Plugins {{{1
" --------------------------------------------------------------------------
call plug#begin(system('echo -n "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/plugged"'))
    " Colorschemes
    Plug 'lifepillar/vim-gruvbox8'

    " Show all available colors
    Plug 'guns/xterm-color-table.vim'

    " Support for repeating actions of plugins using '.'
    Plug 'tpope/vim-repeat'

    " Debugging
    " Plug 'puremourning/vimspector'

    " File browser
    Plug 'preservim/nerdtree'

    " For commenting code using shortcuts
    Plug 'preservim/nerdcommenter'

    " Enhanced support for character pairs (e.g. parentheses, brackets)
    Plug 'tpope/vim-surround'
    Plug 'jiangmiao/auto-pairs'

    " Colorized parentheses
    Plug 'frazrepo/vim-rainbow'

    " Linter (recognizes syntax errors in code)
    " Plug 'dense-analysis/ale'

    " Git diff in sign column
    Plug 'airblade/vim-gitgutter'

    " Git wrapper for vim
    Plug 'tpope/vim-fugitive'

    Plug 'vim-scripts/taglist.vim'

    " Status line
    Plug 'itchyny/lightline.vim'

    " Integration of ALE (linter) into lightline (status line)
    " Plug 'maximbaz/lightline-ale'

    " Colorize css color codes (e.g. #689d6a)
    Plug 'ap/vim-css-color'

    " Autocompletion
    Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }
    " Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    " Plug 'neoclide/coc.nvim', {'branch': 'release'}

    " Enhanced rust support
    " Plug 'rust-lang/rust.vim'

    " Markdown preview
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

    " Latex preview
    Plug 'xuhdev/vim-latex-live-preview'

    " Enhanced latex support
    Plug 'lervag/vimtex'

    " Snippets
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'

    " CSV support
    Plug 'zhaocai/csv.vim'
call plug#end()
nnoremap <silent> K :call <SID>show_documentation()<CR>

" }}}1

" --------------------------------------------------------------------------
" NERDTree {{{1
" --------------------------------------------------------------------------
" Start NERDTree and put the cursor back in the other window.
"autocmd VimEnter * NERDTree | wincmd p

" Change bookmarks file location
let g:NERDTreeBookmarksFile=stdpath('data') . '/NERDTreeBookmarks'

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" Shortcuts
" nnoremap <C-n> :NERDTree<CR>
nnoremap <leader>ee :NERDTreeToggle<CR>
nnoremap <leader>er :NERDTreeFocus<CR>
nnoremap <leader>ef :NERDTreeFind<CR>

" --------------------------------------------------------------------------
" NERDCommenter {{{1
" --------------------------------------------------------------------------

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1

" --------------------------------------------------------------------------
" GitGutter {{{1
" --------------------------------------------------------------------------
highlight GitGutterAdd guifg=#689d6a ctermfg=Green
highlight GitGutterChange guifg=#d79921 ctermfg=Yellow
highlight GitGutterDelete guifg=#cc241d ctermfg=Red
let g:gitgutter_enabled = 1

" Compact git status for statusline
function! GitStatus()
    let [a,m,r] = GitGutterGetHunkSummary()
    if (a == 0 && m == 0 && r == 0)
        return printf('')
    elseif (a != 0 && m == 0 && r == 0)
        return printf('+%d', a)
    elseif (a == 0 && m != 0 && r == 0)
        return printf('~%d', m)
    elseif (a != 0 && m != 0 && r == 0)
        return printf('+%d ~%d', a, m)
    elseif (a == 0 && m == 0 && r != 0)
        return printf('-%d', r)
    elseif (a != 0 && m == 0 && r != 0)
        return printf('+%d -%d', a, r)
    elseif (a == 0 && m != 0 && r != 0)
        return printf('~%d -%d', m, r)
    elseif (a != 0 && m != 0 && r != 0)
        return printf('+%d ~%d -%d', a, m, r)
endfunction

" Disable all key mappings
let g:gitgutter_map_keys = 0

" Shortcuts
nmap ) <Plug>(GitGutterNextHunk)
nmap ( <Plug>(GitGutterPrevHunk)

" --------------------------------------------------------------------------
" Lightline {{{1
" --------------------------------------------------------------------------
let g:lightline = {
    \ 'colorscheme': 'gruvbox',
    \ 'active': {
    \     'left': [ [ 'mode', 'paste' ],
    \             [ 'gitstatus', 'readonly', 'filename', 'modified' ] ],
    \     'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
    \              [ 'percent', 'lineinfo' ],
    \              [ 'fileformat', 'fileencoding', 'filetype', 'gitbranch' ] ]
    \ },
    \ 'component_function': {
    \    'gitbranch': 'FugitiveHead',
    \     'gitstatus': 'GitStatus',
    \    'fileformat': 'LightlineFileformat',
    \    'fileencoding': 'LightlineFileencoding',
    \    'filetype': 'LightlineFiletype'
    \ },
    \ }

let g:lightline.component_expand = {
    \ 'tabs': 'lightline#tabs',
    \ 'linter_checking': 'lightline#ale#checking',
    \ 'linter_infos': 'lightline#ale#infos',
    \ 'linter_warnings': 'lightline#ale#warnings',
    \ 'linter_errors': 'lightline#ale#errors',
    \ 'linter_ok': 'lightline#ale#ok',
    \ }

let g:lightline.component_type = {
    \ 'linter_checking': 'right',
    \ 'linter_infos': 'right',
    \ 'linter_warnings': 'warning',
    \ 'linter_errors': 'error',
    \ 'linter_ok': 'right',
    \ 'lineinfo': 'right',
    \ }

function! LightlineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightlineFileencoding()
  return winwidth(0) > 70 ? &fileencoding : ''
endfunction

function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

let g:lightline#ale#indicator_checking = ""
let g:lightline#ale#indicator_infos = ""
let g:lightline#ale#indicator_warnings = ""
let g:lightline#ale#indicator_errors = ""
let g:lightline#ale#indicator_ok = ""

" --------------------------------------------------------------------------
" Taglist {{{1
" --------------------------------------------------------------------------
nnoremap <silent> <leader>t :TlistToggle<CR>

" --------------------------------------------------------------------------
" ALE {{{1
" --------------------------------------------------------------------------

" " Keybindings for navigating between error and warnings
" nmap <silent> <C-k> <Plug>(ale_previous_wrap)
" nmap <silent> <C-j> <Plug>(ale_next_wrap)
" 
" " Keybindings for refactoring
" nnoremap <silent> <leader>at :ALEToggle<CR>
" nnoremap <silent> <leader>ad :ALEGoToDefinition<CR>
" nnoremap <silent> <leader>af :ALEFindReferences<CR>
" nnoremap <silent> <leader>aa :ALECodeAction<CR>
" nnoremap <silent> <leader>ar :ALERename<CR>
" 
" " let g:ale_sign_error = '>>'
" " let g:ale_sign_warning = '--'
" 
" highlight ALEErrorSign ctermbg=9
" highlight link ALEStyleErrorSign ALEErrorSign
" highlight ALEError ctermbg=1
" highlight link ALEStyleError ALEError
" 
" highlight ALEWarningSign ctermbg=3
" highlight link ALEStyleWarningSign ALEWarningSign
" highlight ALEWarning ctermbg=8
" highlight link ALEStyleWarning ALEWarning
" 
" highlight link ALEInfoSign ALEWarningSign
" highlight link ALEStyleInfoSign ALEInfoSign
" highlight link ALEInfo ALEWarning

" --------------------------------------------------------------------------
" YouCompleteMe {{{1
" --------------------------------------------------------------------------
" let g:ycm_autoclose_preview_window_after_completion = 1

" Turn off automatic popups during typing
" let g:ycm_auto_trigger = 0

" Turn off automatic documentation popup at cursor location
" let g:ycm_auto_hover = ''

" Toggle documentation at cursor location
" nmap <leader>s <plug>(YCMHover)




" Use preview popup instead of preview window
" set previewpopup=height:15,width:80,highlight:PMenu
" set completeopt+=popup
" set completepopup=height:20,width:80,border:off,highlight:PMenu

" Minimum chars to type for identifer-based completion shows
"let g:ycm_min_num_of_chars_for_completion = 99

" Get keywords/identifiers of database of current programming language
"let g:ycm_seed_identifiers_with_syntax = 1

" Limit the number of suggestion shown to increase performance...
" ...in semantic-based enginea (as-you-type popup)
" let g:ycm_max_num_candidates = 50
" ...in identifer-based engine (popup after typing for example '.')
" let g:ycm_max_num_identifier_candidates = 10

" --------------------------------------------------------------------------
" Coc.nvim {{{1
" --------------------------------------------------------------------------
" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? "\<C-n>" :
"       \ <SID>check_back_space() ? "\<TAB>" :
"       \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" 
" function! s:check_back_space() abort
"   let col = col('.') - 1
"   return !col || getline('.')[col - 1]  =~# '\s'
" endfunction

" --------------------------------------------------------------------------
" Vimspector {{{1
" --------------------------------------------------------------------------
" let g:vimspector_enable_mappings = 'HUMAN'
" 
" " mnemonic 'di' = 'debug inspect'
" " for normal mode - the word under the cursor
" nmap <Leader>di <Plug>VimspectorBalloonEval
" " for visual mode, the visually selected text
" xmap <Leader>di <Plug>VimspectorBalloonEval

" --------------------------------------------------------------------------
" vim-rainbow {{{1
" --------------------------------------------------------------------------
autocmd FileType rust,c,cpp call rainbow#load()
let g:rainbow_ctermfgs = ['lightblue', 'lightgreen', 'yellow', 'red', 'magenta']

" --------------------------------------------------------------------------
" Markdown Preview {{{1
" --------------------------------------------------------------------------
autocmd FileType markdown nmap <buffer> <leader>m :MarkdownPreview<CR>

let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0
    \ }

" --------------------------------------------------------------------------
" Latex Preview {{{1
" --------------------------------------------------------------------------
autocmd FileType plaintex,tex nmap <buffer> <leader>m :LLPStartPreview<CR>

" PDF viewer
let g:livepreview_previewer = 'zathura'

" Don't recompile when the cursor holds (only when file is written to disk)
let g:livepreview_cursorhold_recompile = 0

" Use biber instead of bibtex
let g:livepreview_use_biber = 1

" --------------------------------------------------------------------------
" VimTex {{{1
" --------------------------------------------------------------------------
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0

set conceallevel=1
let g:tex_conceal='abdmg'

" --------------------------------------------------------------------------
" csv.vim {{{1
" --------------------------------------------------------------------------
let g:csv_highlight_column = 'y'



" function! HandleURL()
"   let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;()]*')
"   let s:uri = shellescape(s:uri, 1)
"   echom s:uri
"   if s:uri != ""
"         silent exec "!xdg-open '".s:uri."'"
"     :redraw!
"   else
"     echo "No URI found in line."
"   endif
" endfunction
" 
" nmap <leader>z yiW:!xdg-open <c-r>" &<cr>
" 
" function! HandleNoteLink()
"     let lineList = getline(1, '$')
"     let fileString = join(lineList, "\n")
"     let moreIdsToGo = v:true
"     let l:startIndex = 0
" 
"     while (moreIdsToGo)
"         let l:uri = matchstrpos(fileString, '\[\[[a-zA-Z0-9]*\]\]', startIndex)
"         echom l:uri[0]
"         echom l:uri[1]
"         echom l:uri[2]
"         echom len(fileString)
"         let l:startIndex = l:uri[2]
"         if l:uri[2] >= len(fileString)
"             let moreIdsToGo = v:false
"         endif
"     endwhile
" endfunction
"
" --------------------------------------------------------------------------
" UltiSnips {{{1
" --------------------------------------------------------------------------
let g:UltiSnipsExpandTrigger="<leader><leader>"
let g:UltiSnipsJumpForwardTrigger="<C-j>"
let g:UltiSnipsJumpBackwardTrigger="<C-k>"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "my_snippets"]

" --------------------------------------------------------------------------
" Deoplete {{{1
" --------------------------------------------------------------------------
let g:deoplete#enable_at_startup = 1
