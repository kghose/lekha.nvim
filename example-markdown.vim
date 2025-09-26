" Creature comforts for writing a novel with NeoVim
"
" Hardwrap at 80 columns
setlocal textwidth=80
" Nice vertical stripe at 80 columns
set colorcolumn=80

" Set block cursor all the time
set guicursor=n-v-c-i:block

" Activate spelling check
setlocal spell spelllang=en_us
setlocal spellfile=spellings.en.utf-8.add
syntax on

colorscheme morning 

" Minimal yet informative status line
setlocal statusline=
setlocal statusline+=L%l\ 
" wordcount() doesn't have a cursor_words property for visual mode. We use
" get() with a fallback otherwise we get an error and the statusline is reset
" Thanks to @seandewar:matrix.org
setlocal statusline+=%{get(wordcount(),'cursor_words',get(wordcount(),'visual_words'))}/%{wordcount().words}\ words\ (%P)
" Display the file modified flag
setlocal statusline+=%m
" Use Lekha's per chapter word count
setlocal statusline+=%=%{%v:lua.require'lekha'.current_chapter()%}\ 

setlocal signcolumn=yes "Always show gutter
GitGutterEnable
hi clear SignColumn

" https://github.com/preservim/vim-wordy
" Wordy adverbs

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

" Run the script to create the epub each time the buffer is written
" This command is why we need to use ++nested in the previous autocommands 
" https://neovim.io/doc/user/autocmd.html#autocmd-nested
" autocmd BufWritePost *.md execute '!./make-book.sh &'

" Handy shortcut to wrap a paragraph
nmap w gq}
