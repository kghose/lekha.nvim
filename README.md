While [outline.nvim](https://github.com/hedyhli/outline.nvim) does most of what I 
needed while writing my novel, I wanted a few additional things.

- Word counts for each chapter
- Quick navigation to TODOs I put in a chapter

## Installation

`git clone` the repository (or just copy the `lua` folder) to somewhere in your
runtime path. Then add something like this to your `markdown.vim`:

```
lua require("lekha").enable()
nmap <Tab> :LekhaGotoChapter
```

Now by hitting Tab twice in normal mode you can access the go to chapter command.


## Features
- [x] List chapters and word counts
- [x] Navigate to chapter
- [ ] Show TODOs
- [ ] Navigate TODOs
- [ ] Show chapter for current line


# References

1. [minimal-bookmarks.nvim](https://github.com/yuriescl/minimal-bookmarks.nvim)
1. [section-wordcount.nvim](https://github.com/dimfeld/section-wordcount.nvim)
