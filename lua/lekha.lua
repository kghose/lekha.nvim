-- Invoke with lua require('lekha').cwc()
--
local M = {}

function words_in_line(line)
	_, n = line:gsub("%S+", "")
	return n
end

-- Treat each top-level heading as a chapter. Count the words for each chapter
function M.compute_chapter_word_count()
        local start = nil
	local start_lines = {}
	local chapter_data = {}

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local chapter_words = 0
	for n, line in ipairs(lines) do
		if line:sub(1, 2) == "# " then
			if start ~= nil then
				chapter_data[start].stop = n - 1
				chapter_data[start].word_count = chapter_words
			end
			start = n
			chapter_words = 0
			chapter_data[start] = {
				heading = line,
				start = start,
				stop = start,
				word_count = 0,
			}
			table.insert(start_lines, start)
		end
		if start ~= nil then
			chapter_words = chapter_words + words_in_line(line)
		end
	end

	if start ~= nil then
		chapter_data[start].stop = table.getn(lines)
		chapter_data[start].word_count = chapter_words
	end

	table.sort(start_lines)
	return {
		start_lines = start_lines,
		info = chapter_data,
	}
end

function M.print_chapter_word_count(chapters)
	-- table.sort(chapters.section_start_lines)
	for i, s in ipairs(chapters.start_lines) do
		print(string.format("%s (%d)", chapters.info[s].heading, chapters.info[s].word_count))
	end
end

function M.cwc()
	M.print_chapter_word_count(M.compute_chapter_word_count())
end

return M
