# Lekha.nvim

![](lekha.nvim.png)

`Lekha` is a minimalist (in appearance and function) NeoVim plugin for novel
writing:

- It expects the work to be all in one file.
- Top level headings (Lines that start with `# `) are interpreted as chapters.
- It periodically computes and displays word counts for chapters and the whole 
  manuscript. Commented text (`<!-- x y z -->`) is not included in the word 
count.
- Lines that contain a string like `TODO:something` appear in a list of TODOs 
  for each chapter. The `something` has to be a single word. Intended use is to 
add a `TODO` in a comment block with details of what TODO.
- It uses NeoVim's native command auto-complete feature to display chapters,
  chapter word counts and TODOs when the `LekhaGoto` command is called (Please
  see screenshot above).
- There is no split pane. This reduces visual clutter while keeping the
  information accessible.


# Installation

`git clone` the repository (or just copy the `lua` folder) to somewhere in your
runtime path. Then add something like this to your `markdown.vim`:

```
-- Register Lekha commands
lua require("lekha").enable()
-- Register a convenient shortcut key 
nmap <Tab> :LekhaGoto<Space>
```
(For a complete example for `~/.config/nvim/ftplugin/markdown.vim` see
[this](example-markdown.vim).)

Now by hitting Tab twice in normal mode you can access the `LekhaGoto` command
and NeoVim's auto-complete will list chapters and TODOs.

Try it out with the [example document](example-text.md)!

## Use in statusline

Add `%{%v:lua.require'lekha'.current_chapter()%}` to the status line to print 
the chapter the cursor is in.

## Other commands

`Lekha` supplies two other commands `LekhaGotoChapter` and `LekhaGotoTodo` where
the auto-completion shows only chapters or TODOs respectively.

# Testing

`lua lekha_test.lua -v`

# Notes

1. I had little trouble writing this NeoVim plugin in Lua though I had never
   written a NeoVim plugin before and didn't know Lua. The NeoVim documentation
   is adequate though I had to supplement with web searches
   for a few things.
1. Vim/NeoVim's editing efficiency impresses me. I have a 140,000 word
   manuscript and Vim/NeoVim handles it without any issue. I used VS Code for a
   long time but when I tried editing the manuscript with it, the simple task of
   word wrapping (which needs a plugin on VS Code) broke in a subtle way making
   it unusable. 
1. I used an O(N) algorithm (N = manuscript length). It takes ~20ms to process a
   140,000 word (~800 kB)text, which is decently fast for an interpreted,
   studiously dynamic language.

## Lua/NeoVim API Concepts
1. Ordered arrays
1. Calling NeoVim commands from Lua
1. Creating autocommands and commands
1. Unit testing with [LuaUnit](https://github.com/bluebird75/luaunit)

# References

1. [outline.nvim](https://github.com/hedyhli/outline.nvim) is both way more
powerful and not powerful enough for my writing needs. It has a split-pane
outline view, but not per-chapter word count and no TODO/bookmark feature. 
1. [minimal-bookmarks.nvim](https://github.com/yuriescl/minimal-bookmarks.nvim)
1. [section-wordcount.nvim](https://github.com/dimfeld/section-wordcount.nvim)
