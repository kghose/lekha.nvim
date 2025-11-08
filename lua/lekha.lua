-- Activate with lua require('lekha').enable()

local M = {}

function process_line(state, chapters, todos)
   -- Start of a new chapter.
   if not state.in_comment and state.line:sub(1, 2) == "# " then
      table.insert(chapters, {
         name = state.line:sub(3, -1),
         line = state.line_n,
         word_count = 0,
      })
      return
   end

   -- Find the first todo in the line
   -- TODOs are meant to be one word reminders
   local todo_idx = state.line:find("TODO:")
   if todo_idx ~= nil then
      table.insert(todos, {
         chapter = #chapters,
         todo = state.line:sub(todo_idx + 5, -1):gsub("^%s+", ""):gsub("%s+$", ""),
         line = state.line_n,
      })
   end

   -- Regular line
   local i = 1
   while true do
      if state.in_comment then
         end_of_comment = state.line:find("-->", i)
         if end_of_comment == nil then
            -- Still in the middle of a block comment
            return
         else
            state.in_comment = false
            i = end_of_comment + 3
         end
      else
         start_of_comment = state.line:find("<!--", i)
         if start_of_comment == nil then
            -- No comment on this line
            _, n = state.line:sub(i, -1):gsub("%S+", "")
            chapters[#chapters].word_count = chapters[#chapters].word_count + n
            return
         else
            -- Count words till comment
            _, n = state.line:sub(i, start_of_comment - 1):gsub("%S+", "")
            chapters[#chapters].word_count = chapters[#chapters].word_count + n
            i = start_of_comment + 4
            state.in_comment = true
         end
      end
      -- We should never reach here
   end
end

M._only_tests = { process_line = process_line }

data_for_buffer = {}

-- Create the table of chapters and todos
function M.process_document()
   -- Variables not declared local, create a global variable that
   -- persists between calls.
   local chapters = {}
   local todos = {}
   local in_comment = false

   local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 0 })

   local state = { line_n = 0, line = "", in_comment = false }
   for line_n, line in ipairs(lines) do
      state.line_n = line_n
      state.line = line
      process_line(state, chapters, todos)
   end

   document_word_count = 0
   for i = 1, #chapters do
      document_word_count = document_word_count + chapters[i].word_count
   end

   data_for_buffer[vim.api.nvim_get_current_buf()] = {
      chapters = chapters,
      todos = todos,
      words = document_word_count,
   }
end

-- List of strings of chapters and/or TODOs depending on args
-- Format is <Chapter #>.<todo #> <Chapter or TODO name> [(word count)]a
-- https://www.lua.org/pil/5.3.html (named arguments hack)
function M.get_targets_list(arg)
   data = data_for_buffer[vim.api.nvim_get_current_buf()]
   if data == nil then return {} end
   local chapters = data.chapters
   local todos = data.todos

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
   data = data_for_buffer[vim.api.nvim_get_current_buf()]
   if data == nil or args.fargs == nil then return end
   local chapters = data.chapters
   local todos = data.todos

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
   data = data_for_buffer[vim.api.nvim_get_current_buf()]
   if data == nil then return "" end
   local chapters = data.chapters
   local todos = data.todos

   local chapter_index = 1
   row, col = unpack(vim.api.nvim_win_get_cursor(0))
   for i, sl in ipairs(chapters) do
      if row < sl.line then break end
      chapter_index = i
   end
   current_chapter = string.format(
      "%d. %s (%d / %d)",
      chapter_index - 1,
      chapters[chapter_index].name,
      chapters[chapter_index].word_count,
      data.words
   )

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
