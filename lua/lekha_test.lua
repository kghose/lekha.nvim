lu = require("luaunit")
lekha = require("lekha")

function testProcessLineNoComment()
   local state = {
      line_n = 1,
      line = "One two three four",
      in_comment = false,
   }
   local chapters = {}
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 0 })
   local todos = {}

   lekha._only_tests.process_line(state, chapters, todos)
   lu.assertEquals(chapters[1].word_count, 4)
end

function testProcessLineSingleSingleLineComment()
   local state = {
      line_n = 1,
      line = "One two<!-- a comment phrase--> three four",
      in_comment = false,
   }
   local chapters = {}
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 0 })
   local todos = {}

   lekha._only_tests.process_line(state, chapters, todos)
   lu.assertEquals(chapters[1].word_count, 4)
end

function testProcessLineMultipleSingleLineComments()
   local state = {
      line_n = 1,
      line = "One two<!-- a comment phrase--> three four <!--another one-->five",
      in_comment = false,
   }
   local chapters = {}
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 0 })
   local todos = {}

   lekha._only_tests.process_line(state, chapters, todos)
   lu.assertEquals(chapters[1].word_count, 5)
end

function testProcessLineStartOfMultiLineComment()
   local state = {
      line_n = 1,
      line = "One two<!-- a comment phrase three four <!--another one five",
      in_comment = false,
   }
   local chapters = {}
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 0 })
   local todos = {}

   lekha._only_tests.process_line(state, chapters, todos)
   lu.assertEquals(chapters[1].word_count, 2)
   lu.assertEquals(state.in_comment, true)
end

function testProcessLineMiddleOfMultiLineComment()
   local state = {
      line_n = 1,
      line = "One two<!-- a comment phrase three four <!--another one five",
      in_comment = true,
   }
   local chapters = {}
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 0 })
   local todos = {}

   lekha._only_tests.process_line(state, chapters, todos)
   lu.assertEquals(chapters[1].word_count, 0)
   lu.assertEquals(state.in_comment, true)
end

function testProcessLineEndOfMultiLineComment()
   local state = {
      line_n = 1,
      line = "a comment phrase ends--> one two",
      in_comment = true,
   }
   local chapters = {}
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 0 })
   local todos = {}

   lekha._only_tests.process_line(state, chapters, todos)
   lu.assertEquals(chapters[1].word_count, 2)
   lu.assertEquals(state.in_comment, false)
end

function testProcessLineNewChapterSymbolInMultiLineComment()
   local state = {
      line_n = 1,
      line = "# should be ignored",
      in_comment = true,
   }
   local chapters = {}
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 0 })
   local todos = {}

   lekha._only_tests.process_line(state, chapters, todos)
   lu.assertEquals(#chapters, 1)
   lu.assertEquals(state.in_comment, true)
end

function testProcessLineWordCountCumulates()
   local state = {
      line_n = 2,
      line = "five six seven",
      in_comment = false,
   }
   local chapters = {}
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 4 })
   local todos = {}

   lekha._only_tests.process_line(state, chapters, todos)
   lu.assertEquals(chapters[1].word_count, 7)
end

function testProcessLineNewChapter()
   local state = {
      line_n = 2,
      line = "# A new begining",
      in_comment = false,
   }
   local chapters = {}
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 4 })
   local todos = {}

   lekha._only_tests.process_line(state, chapters, todos)
   lu.assertEquals(#chapters, 2)
   lu.assertEquals(chapters[1].word_count, 4)
   lu.assertEquals(chapters[2].name, "A new begining")
   lu.assertEquals(chapters[2].line, 2)
   lu.assertEquals(chapters[2].word_count, 0)

   lu.assertEquals(state.in_comment, false)
end

function testProcessLineNewTodo()
   local state = {
      line_n = 2,
      line = "one two <!-- TODO:rewrite heavily ",
      in_comment = false,
   }
   local chapters = {}
   table.insert(chapters, { name = "Preamble", line = 0, word_count = 0 })
   local todos = {}

   lekha._only_tests.process_line(state, chapters, todos)
   lu.assertEquals(#todos, 1)
   lu.assertEquals(todos[1].chapter, 1)
   lu.assertEquals(todos[1].line, 2)
   lu.assertEquals(todos[1].todo, "rewrite")

   lu.assertEquals(chapters[1].word_count, 2)
   lu.assertEquals(state.in_comment, true)
end

os.exit(lu.LuaUnit.run())
