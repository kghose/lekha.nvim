# lekha.nvim

[outline.nvim](https://github.com/hedyhli/outline.nvim) does most of what I 
needed while writing my novel but I wanted a few additional things.

- Word counts for each chapter
- Quick navigation to TODOs I put in a chapter

## Current state
- Use a command to print word count for each chapter.

This is buggy: using it more than once raises an error.


## Planned Features
Replace Outline with a navigation bar (just like outline) except with word
counts for the chapters and links to the TODOs that look like subheadings.

This could be a custom provider for Outline or could be a simplified fork of
Outline with just the navigation pane code preserved.


# References
1. [outline.vim](https://github.com/hedyhli/outline.nvim)
1. [minimal-bookmarks.nvim](https://github.com/yuriescl/minimal-bookmarks.nvim)
1. [section-wordcount.nvim](https://github.com/dimfeld/section-wordcount.nvim)
