local M = {}

-- Return the byte column just after the current (or next) keyword on this line.
-- Unlike Vim's 'w' motion, this never crosses to the following line.
-- Vim's iskeyword setting determines what counts as a word.
function M.end_of_word_col(line, col)
	if col >= #line then
		return #line
	end

	local word_end = vim.fn.matchend(line, [[\k\+]], col)
	return word_end >= 0 and word_end or #line
end

function M.insert_right()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local col = M.end_of_word_col(vim.api.nvim_get_current_line(), cursor[2])
	if col > cursor[2] then
		vim.api.nvim_win_set_cursor(0, { cursor[1], col })
	end
end

return M
