-- Activate with lua require('lekha').enable()

local M = {}

function words_in_line(line)
   _, n = line:gsub("%S+", "")
   return n
end

-- Treat each top-level heading as a chapter. Count the words for each chapter.
-- Treat all lines begining with <!-- as a TODO mark.
function M.process_document()
   -- Module variable to store chapter locations and word counts
   chapters = {}

   -- Module variable to store todo locations
   todos = {}

   -- Variables not declared local, create a global variable that
   -- persists between calls.
   local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 0 })
   local current_chapter = 1 -- Preamble = 1
   local chapter_words = 0
   for n, line in ipairs(lines) do
      if line:sub(1, 2) == "# " then
         chapters[current_chapter].word_count = chapter_words
         table.insert(chapters, { name = line:sub(3, -1), line = n, word_count = 0 })
         current_chapter = current_chapter + 1
         chapter_words = 0
      elseif line:sub(1, 4) == "<!--" then
         table.insert(todos, { chapter = current_chapter, todo = line:sub(5, -1), line = n })
      end
      chapter_words = chapter_words + words_in_line(line)
   end
   chapters[current_chapter].word_count = chapter_words
end

-- List of strings of chapters and TODOs in one go
-- Format is <Chapter #>.<todo #> <Chapter or TODO name> [(word count)]a
-- https://www.lua.org/pil/5.3.html (named arguments hack)
function M.get_targets_list(arg)
   if chapters == nil then return {} end

   local target_list = {}
   local todo_i = 1
   for i = 1, #chapters do
      if arg.chapters and i > 1 then -- Don't show the dummy "Preamble" chapter.
         table.insert(target_list, string.format("%3d %s (%d)", i - 1, chapters[i].name, chapters[i].word_count))
      end
      while arg.todos and todo_i <= #todos and todos[todo_i].chapter == i do
         table.insert(target_list, string.format("%3d.%d %s", i - 1, todo_i, todos[todo_i].todo))
         todo_i = todo_i + 1
      end
   end

   return target_list
end

-- Return just the chapters
function M.get_chapter_list() return M.get_targets_list({ chapters = true, todos = false }) end

-- Return just the todos
function M.get_todo_list() return M.get_targets_list({ chapters = false, todos = true }) end

-- Return everything
function M.get_all_targets_list() return M.get_targets_list({ chapters = true, todos = true }) end

-- NeoVim passes in args when invoking as a user command
-- args.fargs carries the individual space separated arguments
-- We just want the first word (args.fargs[1]) which is in the form X.Y
-- X is the chapter id and Y the todo id (if present)
function M.goto_target(args)
   if chapters == nil or args.fargs == nill then return end

   local line = nil
   -- https://stackoverflow.com/a/15258515
   local dot_i = args.fargs[1]:find(".", 1, true)
   if dot_i == nil then
      -- Goto chapter
      line = chapters[tonumber(args.fargs[1]) + 1].line
   else
      -- Goto todo
      line = todos[tonumber(args.fargs[1]:sub(dot_i + 1, -1))].line
   end
   vim.api.nvim_command(tostring(line))
end

-- Returns a string representation of the chapter the cursor is in
function M.current_chapter()
   if chapters == nil then return "" end

   local chapter_index = 1
   row, col = unpack(vim.api.nvim_win_get_cursor(0))
   for i, sl in ipairs(chapters) do
      if row < sl.line then break end
      chapter_index = i
   end
   current_chapter = string.format("%d %s", chapter_index - 1, chapters[chapter_index].name)

   return current_chapter
end


-- Set up auto commands and user commands for the plugin to work
function M.enable()
   -- Run the word count explicitly the first time
   M.process_document()

   -- Run the word count whenever we stop typing
   -- TODO: Only activate it for this buffer?
   vim.api.nvim_create_autocmd("CursorHold", {
      pattern = { "*.md" },
      callback = M.process_document,
   })
   vim.api.nvim_create_autocmd("CursorHoldI", {
      pattern = { "*.md" },
      callback = M.process_document,
   })

   -- :h :command-nargs
   -- nargs has to be in single quotes "+" won't work ...
   vim.api.nvim_create_user_command(
      "LekhaGotoChapter",
      M.goto_target,
      { desc = "Go to chapter", nargs = "+", complete = M.get_chapter_list }
   )

   vim.api.nvim_create_user_command(
      "LekhaGotoTodo",
      M.goto_target,
      { desc = "Go to TODO", nargs = "+", complete = M.get_todo_list }
   )

   vim.api.nvim_create_user_command(
      "LekhaGoto",
      M.goto_target,
      { desc = "Go to target", nargs = "+", complete = M.get_all_targets_list }
   )
end

return M
