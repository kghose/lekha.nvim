set background=light
set termguicolors

hi clear

let g:colors_name = "lekha-light"

hi nCursor guifg=black guibg=blue
hi iCursor guifg=white guibg=black
setlocal guicursor=n-v-c:block-nCursor,i:block-iCursor

hi htmlH1 gui=underline guifg=blue
hi htmlItalic gui=italic
hi htmlBold gui=bold
hi Comment gui=italic guifg=green

hi PmenuSel cterm=underline,reverse gui=bold guibg=yellow blend=0
