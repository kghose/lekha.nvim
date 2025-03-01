-- Activate with lua require('lekha').enable()

local M = {}

function words_in_line(line)
	_, n = line:gsub("%S+", "")
	return n
end

-- Treat each top-level heading as a chapter. Count the words for each chapter
function M.compute_chapter_word_count()
	-- Module variable to store chapter locations and word counts
	chapters = {}

	-- Module variable to store todo locations
	todos = {}

	-- Variables not declared local, create a global variable that
	-- persists between calls.
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	table.insert(chapters, {
		name = "Preamble",
		line = 0,
		word_count = 0,
	})
	local current_chapter = 1 -- Preamble = 1
	local chapter_words = 0
	for n, line in ipairs(lines) do
		if line:sub(1, 2) == "# " then
			chapters[current_chapter].word_count = chapter_words
			table.insert(chapters, {
				name = line:sub(3, -1),
				line = n,
				word_count = 0,
			})
			current_chapter = current_chapter + 1
			chapter_words = 0
		elseif line:sub(1, 4) == "<!--" then
			table.insert(todos, {
				chapter = current_chapter,
				todo = line:sub(5, -1),
				line = n,
			})
		end
		chapter_words = chapter_words + words_in_line(line)
	end
	chapters[current_chapter].word_count = chapter_words
end

-- This returns an array table of strings that are formatted as
-- N MM MM (X)
-- Where
--   N is the sequential chapter number,
--   MM MM is the chapter name
--   X is the word count
-- This is a visually acceptable way to list the information and
-- it can also be used as an input to the "go to chapter" command
-- which just uses the first term to index into the data
function M.get_chapter_info_list()
	local chapter_list = {}
	if chapters == nil then
		return chapter_list
	end

	for i = 2, #chapters do
		table.insert(chapter_list, string.format("%3d %s (%d)", i - 1, chapters[i].name, chapters[i].word_count))
	end

	return chapter_list
end

-- NeoVim passes in args
-- args.args carries the full string
-- args.fargs carries the individual space separated arguments
-- We just want the first word which is the chapter number
-- Chapter number needs +1 to get the right index in `chapters`
function M.goto_chapter(args)
	if chapters == nil then
		return
	end

	if args.args == nil then
		return
	end

	local line = chapters[tonumber(args.fargs[1]) + 1].line
	vim.api.nvim_command(tostring(line))
end

-- Returns a string representation of the chapter the cursor is in
function M.current_chapter()
	if chapters == nil then
		return ""
	end

	local chapter_index = 1
	row, col = unpack(vim.api.nvim_win_get_cursor(0))
	for i, sl in ipairs(chapters) do
		if row < sl.line then
			break
		else
			chapter_index = i
		end
	end
	current_chapter = string.format("%d %s", chapter_index - 1, chapters[chapter_index].name)

	return current_chapter
end

-- Returns and array table of strings formatted as
-- number item (chapter)
-- This lists the todos and can be passed (as a completion, like the chapters)
-- to the go to todo function to take us to the todo item
function M.get_todo_list()
	local todo_list = {}
	if todos == nil then
		return todo_list
	end

	for i, s in ipairs(todos) do
		table.insert(todo_list, string.format("%3d [%d] %s", i, s.chapter, s.todo))
	end

	return todo_list
end

-- NeoVim passes in args
-- args.args carries the full string
-- args.fargs carries the individual space separated arguments
-- We just want the first word which is the todo number
function M.goto_todo(args)
	if todos == nil then
		return
	end

	if args.args == nil then
		return
	end

	local todo = todos[tonumber(args.fargs[1])]
	if todo == nil then
		return
	end
	vim.api.nvim_command(tostring(todo.line))
end

-- List of strings of chapters and TODOs in one go
-- Format is <Chapter #>.<todo #> <Chapter or TODO name> [(word count)]
function M.get_target_list()
	local target_list = {}
	if chapters == nil then
		return string_list
	end

	local todo_i = 1
	for i = 1, #chapters do
		table.insert(target_list, string.format("%3d %s (%d)", i - 1, chapters[i].name, chapters[i].word_count))
		while todo_i <= #todos and todos[todo_i].chapter == i do
			table.insert(target_list, string.format("%3d.%d %s", i - 1, todo_i, todos[todo_i].todo))
			todo_i = todo_i + 1
		end
	end

	return target_list
end

-- NeoVim passes in args
-- args.args carries the full string
-- args.fargs carries the individual space separated arguments
-- We just want the first word (args.fargs[1]) which is in the form X.Y
-- X is the chapter id and Y the todo id (if present)
function M.goto_target(args)
	if chapters == nil then
		return
	end

	if args.args == nil then
		return
	end

	local line = nil
	-- https://stackoverflow.com/a/15258515
	local dot_i = args.fargs[1]:find(".", 1, true)
	if dot_i == nil then
		-- print(args.fargs[1])
		line = chapters[tonumber(args.fargs[1]) + 1].line
	else
		-- print(args.fargs[1]:sub(dot_i+1, -1))
		line = todos[tonumber(args.fargs[1]:sub(dot_i + 1, -1))].line
	end
	vim.api.nvim_command(tostring(line))
end

function M.enable()
	-- Run the word count explicitly the first time
	M.compute_chapter_word_count()

	-- Run the word count whenever we stop typing
	-- TODO: Only activate it for this buffer?
	vim.api.nvim_create_autocmd("CursorHold", {
		pattern = { "*.md" },
		callback = M.compute_chapter_word_count,
	})
	vim.api.nvim_create_autocmd("CursorHoldI", {
		pattern = { "*.md" },
		callback = M.compute_chapter_word_count,
	})

	-- :h :command-nargs
	-- nargs has to be in single quotes "+" won't work ...
	vim.api.nvim_create_user_command(
		"LekhaGotoChapter",
		M.goto_chapter,
		{ desc = "Go to chapter", nargs = "+", complete = M.get_chapter_info_list }
	)

	vim.api.nvim_create_user_command(
		"LekhaGotoTodo",
		M.goto_todo,
		{ desc = "Go to TODO", nargs = "+", complete = M.get_todo_list }
	)

	vim.api.nvim_create_user_command(
		"LekhaGotoTarget",
		M.goto_target,
		{ desc = "Go to target", nargs = "+", complete = M.get_target_list }
	)
end

return M
