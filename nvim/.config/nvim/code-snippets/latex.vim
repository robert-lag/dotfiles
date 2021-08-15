" Begin & end
autocmd FileType tex,plaintex inoremap ;bg \begin{}<Esc>F}i
autocmd FileType tex,plaintex inoremap ;ed \end{}<Esc>F}i

" Section definitions
autocmd FileType tex,plaintex inoremap ;sc \section{}<Esc>F}i
autocmd FileType tex,plaintex inoremap ;ssc \subsection{}<Esc>F}i
autocmd FileType tex,plaintex inoremap ;sssc \subsubsection{}<Esc>F}i
autocmd FileType tex,plaintex inoremap ;ssssc \subsubsubsection{}<Esc>F}i
autocmd FileType tex,plaintex inoremap ;sssssc \subsubsubsubsection{}<Esc>F}i
autocmd FileType tex,plaintex inoremap ;ssssssc \subsubsubsubsubsection{}<Esc>F}i
