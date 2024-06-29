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
autocmd FileType c,cpp,java,php,ruby,python,rust,haskell,r,sh,zsh,conf autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

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
nnoremap <leader>s :setlocal spell! spelllang=en_us,de<CR>

" Correct last spelling mistake
nnoremap <leader>d <c-g>u<Esc>[s1z=`]a<c-g>u

" Programming snippets
nnoremap <Space><Space> <Esc>/<++><CR>"_c4l
source $XDG_CONFIG_HOME/nvim/code-snippets/rust.vim
source $XDG_CONFIG_HOME/nvim/code-snippets/latex.vim

" Zettelkasten script shortcuts
nnoremap <leader>bh :silent !dmenu-zettelkasten-history-viewer -o<cr>
nnoremap <leader>bl :silent !dmenu-zettelkasten-history-viewer -l<cr>
nnoremap <leader>bo :silent !cat<Space>"%"<Space>\|<Space>dmenu-zettelkasten-link-handler<Space>-o<cr>

" Move between changes
nnoremap <leader>n ]c
nnoremap <leader>N [c
nnoremap <n ]c
nnoremap <N [c

" Move between windows
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
nnoremap <leader>w <C-w><C-w>
nnoremap <h <C-w>h
nnoremap <j <C-w>j
nnoremap <k <C-w>k
nnoremap <l <C-w>l
nnoremap <w <C-w><C-w>

" nnoremap <C-h> <C-w>h
" nnoremap <C-j> <C-w>j
" nnoremap <C-k> <C-w>k
" nnoremap <C-l> <C-w>l

" This remapping is needed to ensure that nvim doesn't wait
" for further input after the second '<' is typed
nnoremap << <<

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

" --------------------------------------------------------------------------
" Plugin List {{{2
" --------------------------------------------------------------------------
call plug#begin(system('echo -n "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/plugged"'))
    " Colorschemes
    Plug 'joshdick/onedark.vim'

    " Show all available colors with ':XTermColorTable'
    Plug 'guns/xterm-color-table.vim'

    " Support for repeating actions of plugins using '.'
    Plug 'tpope/vim-repeat'

    " For commenting code using shortcuts
    Plug 'preservim/nerdcommenter'

    " Enhanced support for character pairs (e.g. parentheses, brackets)
    Plug 'tpope/vim-surround'
    Plug 'jiangmiao/auto-pairs'

    " Colorized parentheses
    Plug 'frazrepo/vim-rainbow'

    " Git diff in sign column
    Plug 'airblade/vim-gitgutter'

    " Git wrapper for vim
    " Needed for git support in lightline
    Plug 'tpope/vim-fugitive'

    " Status line
    Plug 'itchyny/lightline.vim'

    " Colorize css color codes (e.g. #689d6a)
    Plug 'ap/vim-css-color'

    " Autocompletion
    Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }

    " Markdown preview
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

    " Markdown Table Of Contents generator
    Plug 'mzlogin/vim-markdown-toc'

    " Latex preview
    Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }

    " Enhanced latex support
    Plug 'lervag/vimtex'

    " Snippets
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'

    " CSV support
    " Plug 'chrisbra/csv.vim'
    Plug 'mechatroner/rainbow_csv'
call plug#end()

" }}}2

" --------------------------------------------------------------------------
" NERDCommenter {{{2
" --------------------------------------------------------------------------

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1

" Don't create default mappings as they are declared explicitly
let g:NERDCreateDefaultMappings = 0
noremap <leader>c <Plug>NERDCommenterToggle

" Some default mappings that would be created by this plugin
" nnoremap <leader>cc <Plug>NERDCommenterComment
" nnoremap <leader>cu <Plug>NERDCommenterUncomment
" nnoremap <leader>cn <Plug>NERDCommenterNested
" nnoremap <leader>c<space> <Plug>NERDCommenterToggle
" nnoremap <leader>cm <Plug>NERDCommenterMinimal
" nnoremap <leader>ci <Plug>NERDCommenterInvert
" nnoremap <leader>cs <Plug>NERDCommenterSexy
" nnoremap <leader>cy <Plug>NERDCommenterYank
" nnoremap <leader>c$ <Plug>NERDCommenterToEOL
" nnoremap <leader>cA <Plug>NERDCommenterAppend
" nnoremap <leader>ca <Plug>NERDCommenterAltDelims

" --------------------------------------------------------------------------
" GitGutter {{{2
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
nnoremap ) <Plug>(GitGutterNextHunk)
nnoremap ( <Plug>(GitGutterPrevHunk)

" --------------------------------------------------------------------------
" Lightline {{{2
" --------------------------------------------------------------------------
let g:lightline = {
    \ 'colorscheme': 'xrdb',
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
" YouCompleteMe {{{2
" --------------------------------------------------------------------------
let g:ycm_autoclose_preview_window_after_completion = 1

" Turn off automatic popups during typing
" let g:ycm_auto_trigger = 0

" Turn off automatic documentation popup at cursor location
" let g:ycm_auto_hover = ''

" Toggle documentation at cursor location
nnoremap <leader>f <plug>(YCMHover)

" Use preview popup instead of preview window
"set previewpopup=height:15,width:80,highlight:PMenu
"set completeopt+=popup
"set completepopup=height:20,width:80,border:off,highlight:PMenu

" Minimum chars to type for identifer-based completion shows
"let g:ycm_min_num_of_chars_for_completion = 99

" Get keywords/identifiers of database of current programming language
let g:ycm_seed_identifiers_with_syntax = 1

" Limit the number of suggestion shown to increase performance...
" ...in semantic-based enginea (as-you-type popup)
let g:ycm_max_num_candidates = 50
" ...in identifer-based engine (popup after typing for example '.')
let g:ycm_max_num_identifier_candidates = 10

" --------------------------------------------------------------------------
" vim-rainbow {{{2
" --------------------------------------------------------------------------
autocmd FileType rust,c,cpp call rainbow#load()
let g:rainbow_ctermfgs = ['lightblue', 'lightgreen', 'yellow', 'red', 'magenta']

" --------------------------------------------------------------------------
" Markdown Preview {{{2
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
    \ 'disable_filename': 1
    \ }

" --------------------------------------------------------------------------
" Markdown Table Of Contents Generator {{{2
" --------------------------------------------------------------------------
let g:vmt_fence_text = 'TOC'
let g:vmt_fence_closing_text = '/TOC'
let g:vmt_list_item_char = '-'

" --------------------------------------------------------------------------
" Latex Preview {{{2
" --------------------------------------------------------------------------
autocmd FileType plaintex,tex nmap <buffer> <leader>m :LLPStartPreview<CR>

" PDF viewer
let g:livepreview_previewer = 'zathura'

" Don't recompile when the cursor holds (only when file is written to disk)
let g:livepreview_cursorhold_recompile = 0

" Use biber instead of bibtex
let g:livepreview_use_biber = 1

" --------------------------------------------------------------------------
" VimTex {{{2
" --------------------------------------------------------------------------
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0

set conceallevel=1
let g:tex_conceal='abdmg'

" --------------------------------------------------------------------------
" csv.vim {{{2
" --------------------------------------------------------------------------
let g:csv_highlight_column = 'y'

" --------------------------------------------------------------------------
" UltiSnips {{{2
" --------------------------------------------------------------------------
let g:UltiSnipsExpandTrigger="<return>"
let g:UltiSnipsJumpForwardTrigger="<C-j>"
let g:UltiSnipsJumpBackwardTrigger="<C-k>"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "my_snippets"]

"
" Onedark colorscheme {{{2
" --------------------------------------------------------------------------

let g:onedark_termcolors=256
let g:onedark_color_overrides = {
\ "background": {"gui": "#1e2127", "cterm": "0", "cterm16": "0" },
\}

colorscheme onedark

" }}}1

" --------------------------------------------------------------------------
" Colors {{{1
" --------------------------------------------------------------------------
" Colors need to be defined after setting the colorscheme, so that
" autocmd ColorScheme works correctly

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
