-- Run from the repository root:
-- nvim --headless -u NONE -l tests/nvim/word_navigation.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/dotfiles/nvim")
vim.opt.virtualedit = "onemore"

local nav = require("ava.word_navigation")
local function eq(actual, expected)
	assert(actual == expected, string.format("Expected %s, got %s", tostring(expected), tostring(actual)))
end

eq(nav.end_of_word_col("aa aaa aaaaa", 8), 12) -- aa aaa a|aaaa
eq(nav.end_of_word_col("aa aaa aaaaa", 3), 6) -- aa |aaa aaaaa
eq(nav.end_of_word_col("aa aaa aaaaa", 12), 12) -- end of line, do not wrap
eq(nav.end_of_word_col("foo->bar", 4), 8) -- punctuation before keyword
eq(nav.end_of_word_col("foo!!!", 3), 6) -- no next word, stop at EOL
eq(nav.end_of_word_col("", 0), 0)

vim.api.nvim_buf_set_lines(0, 0, -1, false, { "aa aaa aaaaa", "second line" })
vim.api.nvim_win_set_cursor(0, { 1, 8 })
nav.insert_right()
eq(vim.api.nvim_win_get_cursor(0)[2], 12)

nav.insert_right()
local cursor = vim.api.nvim_win_get_cursor(0)
eq(cursor[1], 1)
eq(cursor[2], 12)

-- Visual mode must land on the last character, not one past the line end.
vim.api.nvim_win_set_cursor(0, { 1, 8 })
nav.visual_right()
eq(vim.api.nvim_win_get_cursor(0)[2], 11)
nav.visual_right()
eq(vim.api.nvim_win_get_cursor(0)[2], 11)
eq(vim.api.nvim_win_get_cursor(0)[1], 1)

-- Ensure the actual user key binding calls this function, while Ctrl+Left stays unchanged.
require("config.keymaps")
local right_map = vim.fn.maparg("<C-Right>", "i", false, true)
assert(type(right_map.callback) == "function", "Insert Ctrl+Right mapping not registered")
local visual_right_map = vim.fn.maparg("<C-Right>", "x", false, true)
assert(type(visual_right_map.callback) == "function", "Visual Ctrl+Right mapping not registered")
local left_map = vim.fn.maparg("<C-Left>", "i", false, true)
eq(left_map.rhs, "<C-o>b")

print("word navigation checks passed")
vim.cmd.quitall({ bang = true })
