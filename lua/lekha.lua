-- Activate with lua require('lekha').enable()

local M = {}

function words_in_line(line)
	_, n = line:gsub("%S+", "")
	return n
end

-- Module global to store chapter locations and word counts
local chapters = {}

-- Treat each top-level heading as a chapter. Count the words for each chapter
function M.compute_chapter_word_count()
	-- Ordered array table of chapter start lines
	local start_line_array = {}
	-- Ordered array table of chapter names
	local chapter_names = {}
	-- map chapter name to first line
	local name_to_line_map = {}
	-- map start line to chapter info
	local line_to_info_map = {}

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local chapter_words = 0
	-- if start is not declared as nil and used in the loop below, apparently
	-- it declares a module global called start that persists bewtween
	-- function calls
	local start = nil 
	for n, line in ipairs(lines) do
		if line:sub(1, 2) == "# " then
			if start ~= nil then
				line_to_info_map[start].stop = n - 1
				line_to_info_map[start].word_count = chapter_words
			end
			heading = line:sub(3, -1)
			start = n
			chapter_words = 0
			line_to_info_map[start] = {
				heading = heading,
				start = start,
				stop = start,
				word_count = 0,
			}
			name_to_line_map[heading] = start
			table.insert(start_line_array, start)
			table.insert(chapter_names, heading)
		end
		if start ~= nil then
			chapter_words = chapter_words + words_in_line(line)
		end
	end

	if start ~= nil then
		line_to_info_map[start].stop = table.getn(lines)
		line_to_info_map[start].word_count = chapter_words
	end

	-- In Lua only an array table can be sorted
	-- table.sort(start_line_array)
	chapters = {
		start_line_array = start_line_array,
		chapter_names = chapter_names,
		name_to_line_map = name_to_line_map,
		line_to_info_map = line_to_info_map,
	}
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

	for i, s in ipairs(chapters.start_line_array) do
		local info = chapters.line_to_info_map[s]
		table.insert(chapter_list, string.format("%3d %s (%d)", i, info.heading, info.word_count))
	end

	return chapter_list
end


-- NeoVim passes in args
-- args.args carries the full string
-- args.fargs carries the individual space separated arguments
-- We just want the first word which is the chapter number
function M.goto_chapter(args)
	if chapters == nil then
		return
	end

	if args.args == nil then
		return
	end

	local line = chapters.start_line_array[tonumber(args.fargs[1])]
	if line == nil then
		return
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
end

return M
