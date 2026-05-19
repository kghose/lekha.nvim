set background=dark
set termguicolors

hi clear

let g:colors_name = "lekha-dark"

hi nCursor guifg=white guibg=blue
hi iCursor guifg=black guibg=white
setlocal guicursor=n-v-c:block-nCursor,i:block-iCursor

hi htmlH1 gui=underline guifg=yellow
hi htmlItalic gui=italic
hi htmlBold gui=bold
hi Comment gui=italic guifg=lightred

hi PmenuSel cterm=underline,reverse gui=bold,reverse blend=0
