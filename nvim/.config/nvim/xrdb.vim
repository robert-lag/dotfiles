" =============================================================================
" Filename: autoload/lightline/colorscheme/xrdb.vim
" Author: robert
" License: MIT License
" Last Change: 2020/02/15 20:56:45.
" =============================================================================
" This file needs to be copied into the folder:
" ~/.local/share/nvim/plugged/lightline.vim/autoload/lightline/colorscheme/

let s:term_red = 9
let s:term_green = 10
let s:term_yellow = 11
let s:term_blue = 12
let s:term_purple = 13
let s:term_white = 15
let s:term_black = 0
let s:term_grey = 8

let s:mode_foreground = 235

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:p.normal.left = [ [ '#292c33', '#98c379', s:mode_foreground, s:term_green, 'bold' ], [ '#98c379', '#292c33', s:term_green, s:term_black ] ]
let s:p.normal.right = [ [ '#292c33', '#98c379', s:mode_foreground, s:term_green ], [ '#abb2bf', '#3e4452', s:term_white, s:term_grey ], [ '#98c379', '#292c33', s:term_green, s:term_black ] ]
let s:p.inactive.right = [ [ '#292c33', '#61afef', s:mode_foreground, s:term_blue], [ '#abb2bf', '#3e4452', s:term_white, s:term_grey ] ]
let s:p.inactive.left = s:p.inactive.right[1:]
let s:p.insert.left = [ [ '#292c33', '#61afef', s:mode_foreground, s:term_blue, 'bold' ], [ '#61afef', '#292c33', s:term_blue, s:term_black ] ]
let s:p.insert.right = [ [ '#292c33', '#61afef', s:mode_foreground, s:term_blue ], [ '#ABB2BF', '#3E4452', s:term_white, s:term_grey ], [ '#61afef', '#292c33', s:term_blue, s:term_black ] ]
let s:p.replace.left = [ [ '#292c33', '#e06c75', s:mode_foreground, s:term_red, 'bold' ], [ '#e06c75', '#292c33', s:term_red, s:term_black ] ]
let s:p.replace.right = [ [ '#292c33', '#e06c75', s:mode_foreground, s:term_red ], s:p.normal.right[1], [ '#e06c75', '#292c33', s:term_red, s:term_black ] ]
let s:p.visual.left = [ [ '#292c33', '#c678dd', s:mode_foreground, s:term_purple, 'bold' ], [ '#c678dd', '#292c33', s:term_purple, s:term_black ] ]
let s:p.visual.right = [ [ '#292c33', '#c678dd', s:mode_foreground, s:term_purple ], s:p.normal.right[1], [ '#c678dd', '#292c33', s:term_purple, s:term_black ] ]
let s:p.normal.middle = [ [ '#abb2bf', '#292c33', s:term_white, s:term_black ] ]
let s:p.insert.middle = s:p.normal.middle
let s:p.replace.middle = s:p.normal.middle
let s:p.tabline.left = [ s:p.normal.left[1] ]
let s:p.tabline.tabsel = [ s:p.normal.left[0] ]
let s:p.tabline.middle = s:p.normal.middle
let s:p.tabline.right = [ s:p.normal.left[1] ]
let s:p.normal.error = [ [ '#292c33', '#fb4934', s:mode_foreground, s:term_red ] ]
let s:p.normal.warning = [ [ '#292c33', '#fabd2f', s:mode_foreground, s:term_yellow ] ]

let g:lightline#colorscheme#xrdb#palette = lightline#colorscheme#fill(s:p)
