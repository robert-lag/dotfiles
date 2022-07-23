" Print
autocmd FileType rust inoremap ;pp print!("",<Space><++>);<Esc>F"i
autocmd FileType rust inoremap ;pl println!("",<Space><++>);<Esc>F"i
autocmd FileType rust inoremap ;pd println!("DEBUG:<Space>{}",<Space>);<Esc>F)i

" Function definitions
autocmd FileType rust inoremap ;fn fn<Space>(<++>)<Space>{<CR><++><CR>}<Esc>2k$F(i
autocmd FileType rust inoremap ;fr fn<Space>(<++>)<Space>-><Space><++><Space>{<CR><++><CR>}<Esc>2k$F(i

" If
autocmd FileType rust inoremap ;if if<Space><Space>{<CR><++><CR>}<Esc>2k$hi

" Loop - For
autocmd FileType rust inoremap ;lf for<Space><Space>{<CR><++><CR>}<Esc>2k$hi

" Loop - While
autocmd FileType rust inoremap ;lw while<Space><Space>{<CR><++><CR>}<Esc>2k$hi
