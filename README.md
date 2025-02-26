# Lekha.nvim

![](lekha.nvim.png)

For my novel writing needs,
[outline.nvim](https://github.com/hedyhli/outline.nvim) was both way more
powerful than I needed and not powerful enough. 

This plugin is minimalistic (in appearance and function) but is perfect for my
writing needs:

- There is no split pane: It uses NeoVim's auto complete feature to display the
  chapters and word counts when the "jump to chapter" command is called. This
  reduces visual clutter but keeps the information accessible.
- Only looks at top level headings (Lines that start with `# `)
- Currently only provides a jump to chapter command, but I want to add a jump to
  TODO command 

# Installation

`git clone` the repository (or just copy the `lua` folder) to somewhere in your
runtime path. Then add something like this to your `markdown.vim`:

```
lua require("lekha").enable()
nmap <Tab> :LekhaGotoChapter
```

Now by hitting Tab twice in normal mode you can access the go to chapter command.

## Use in statusline

Add `%{%v:lua.require'lekha'.current_chapter()%}` to the status line to print 
the chapter the cursor is in.


# Notes

1. I had little trouble writing the NeoVim plugin in Lua though I had never
   written a NeoVim plugin before and didn't know Lua. The NeoVim documentation
   is adequate though I had to supplement with reddit and stackoverflow searches
   for a few things which were either hard to find keywords for in the API docs,
   or which were not actually that well explained.
1. Vim (and NeoVim's) efficiency impresses me. I have a 140,000 word manuscript
   and the dumb algorithm I implemented here doesn't take any perceptible time
   to run.


# References

1. [minimal-bookmarks.nvim](https://github.com/yuriescl/minimal-bookmarks.nvim)
1. [section-wordcount.nvim](https://github.com/dimfeld/section-wordcount.nvim)
