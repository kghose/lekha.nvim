set background=light
set termguicolors

hi clear

let g:colors_name = "lekha-light"

hi Cursor guifg=white guibg=red
set guicursor=n-v-c:block-Cursor/lCursor,i-ci-ve:ver90-Cursor

hi htmlH1 gui=underline guifg=blue
hi htmlItalic gui=italic
hi htmlBold gui=bold
hi Comment gui=italic guifg=green

hi PmenuSel cterm=underline,reverse gui=bold guibg=yellow blend=0
