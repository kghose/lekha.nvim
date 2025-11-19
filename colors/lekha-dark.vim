set background=dark
set termguicolors

hi clear

let g:colors_name = "lekha-dark"

hi Cursor guibg=yellow
set guicursor=n-v-c:block-Cursor/lCursor,i-ci-ve:ver90-Cursor

hi htmlH1 gui=underline guifg=yellow
hi htmlItalic gui=italic
hi htmlBold gui=bold
hi Comment gui=italic guifg=lightred

hi PmenuSel cterm=underline,reverse gui=bold,reverse blend=0
