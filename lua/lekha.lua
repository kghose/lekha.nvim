-- Activate with lua require('lekha').enable()
--
local M = {}

function words_in_line(line)
	_, n = line:gsub("%S+", "")
	return n
end

local chapters = {}

-- Treat each top-level heading as a chapter. Count the words for each chapter
function M.compute_chapter_word_count()
	-- Ordered array table of chapter start lines
	local start_line_array = {}
	-- Ordered array table of chapter names
	local chapter_names = {}
	-- index start lines by chapter name
	local name_to_line_map = {}
	-- index chapter info by start lines
	local line_to_info_map = {}

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local chapter_words = 0
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
	table.sort(start_line_array)
	chapters = {
		start_line_array = start_line_array,
		chapter_names = chapter_names,
		name_to_line_map = name_to_line_map,
		line_to_info_map = line_to_info_map,
	}
end

function M.print_chapter_word_count()
	if chapters == nil then
		return
	end

	for i, s in ipairs(chapters.start_line_array) do
		local info = chapters.line_to_info_map[s]
		print(string.format("%3d. %s (%d)", i, info.heading, info.word_count))
	end
end

function M.chapter_list()
	if chapters == nil then
		return
	else
		return chapters.chapter_names
	end
end

function M.goto_chapter(args)
	if chapters == nil then
		return
	end

	if args.args == nil then
		return
	end

	local chapter_name = args.args

	local line = chapters.name_to_line_map[chapter_name]
	if line == nil then
		return
	end
	vim.api.nvim_command(string.format("%d", line))
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

	vim.api.nvim_create_user_command("LekhaShowChapters", M.print_chapter_word_count, {})
	-- :h :command-nargs
	-- has to be in single quotes "+" won't work ...
	vim.api.nvim_create_user_command(
		"LekhaGotoChapter",
		M.goto_chapter,
		{ desc = "Go to chapter", nargs = "+", complete = M.chapter_list }
	)
end

return M
