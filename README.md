# Lekha.nvim

![](lekha.nvim.png)

`Lekha` is a minimalist (in appearance and function) NeoVim plugin for novel
writing:

- It expects the work to be all in one file.
- Top level headings (Lines that start with `# `) are interpreted as chapters.
- Lines that start with markdown comments (`<!--`) are interpreted as TODOs.
- It uses NeoVim's native command auto-complete feature to display chapters,
  chapter word counts and TODOs when the `LekhaGoto` command is called (Please
  see screenshot above).
- There is no split pane. This reduces visual clutter but keeps the information
  accessible.


# Installation

`git clone` the repository (or just copy the `lua` folder) to somewhere in your
runtime path. Then add something like this to your `markdown.vim`:

```
-- Register Lekha commands
lua require("lekha").enable()
-- Register a convenient shortcut key 
nmap <Tab> :LekhaGoto<Space>
```

Now by hitting Tab twice in normal mode you can access the go to chapter command
and see and navigate through a list of chapters.

## Use in statusline

Add `%{%v:lua.require'lekha'.current_chapter()%}` to the status line to print 
the chapter the cursor is in.


# Notes

1. I had little trouble writing this NeoVim plugin in Lua though I had never
   written a NeoVim plugin before and didn't know Lua. The NeoVim documentation
   is adequate though I had to supplement with web searches
   for a few things.
1. Vim/NeoVim's editing efficiency impresses me. I have a 140,000 word
   manuscript and Vim/NeoVim handles it without any issue. I used VS Code for a
   long time but when I tried editing the manuscript with it the simple task of
   word wrapping (which needs a plugin on VS Code) broke in a subtle way making
   it unusable. 
1. The algorithm I used here is a O(N) algorithm (N = manuscript length) and
   runs every time the file is edited (It runs after there is a pause in
   editing, not after every keystroke) and takes ~20ms for that size of text
   which is decently fast for an interpreted, studiously dynamic language.

## Lua/NeoVim API Concepts
1. Ordered arrays
1. Calling NeoVim commands from Lua
1. Creating autocommands and commands

# References

1. [outline.nvim](https://github.com/hedyhli/outline.nvim) is both way more
powerful and not powerful enough for my writing needs. It has a split-pane
outline view, but not per-chapter word count and no TODO/bookmark feature. 
1. [minimal-bookmarks.nvim](https://github.com/yuriescl/minimal-bookmarks.nvim)
1. [section-wordcount.nvim](https://github.com/dimfeld/section-wordcount.nvim)
