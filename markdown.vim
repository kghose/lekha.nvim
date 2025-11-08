" Creature comforts for writing a novel with NeoVim
"

" Hide command bar
setlocal cmdheight=0 

" Hardwrap at 80 columns
setlocal textwidth=80
setlocal formatoptions+=t

" Nice vertical stripe at 80 columns
setlocal colorcolumn=80

" Set block cursor all the time
" setlocal guicursor=n-v-c-i:block

" Activate spelling check
" setlocal spell spelllang=en_us
" setlocal spellfile=spellings.en.utf-8.add
" syntax on

" colorscheme industry 

" On NeoVim the wordcount call is slow for large files
" Minimal yet informative status line
setlocal statusline=
setlocal statusline+=%l/%L\ %f\ 
" wordcount() doesn't have a cursor_words property for visual mode. We use
" get() with a fallback otherwise we get an error and the statusline is reset
" Thanks to @seandewar:matrix.org
" setlocal statusline+=%{get(wordcount(),'cursor_words',get(wordcount(),'visual_words'))}/%{wordcount().words}\ words\ (%P)
" Display the file modified flag
setlocal statusline+=%m
" Use Lekha's per chapter word count
setlocal statusline+=%=%{%v:lua.require'lekha'.status_line()%}\ 

" Git stuff
" https://github.com/lewis6991/gitsigns.nvim
lua require("gitsigns").setup()


" Enable https://github.com/kghose/lekha.nvim 
lua require("lekha").enable()
" Map chapter menu to a convenient key
" Don't know how to trigger auto completion automatically ...
nmap <Tab> :LekhaGotoChapter<Space>
nmap <S-Tab> :LekhaGotoTodo<Space>

" Save the buffer automatically after a pause in typing in both 
" Normal and Insert mode
autocmd CursorHold *.md ++nested update 
autocmd CursorHoldI *.md ++nested update

" Handy shortcut to wrap a paragraph
nmap w gq}
