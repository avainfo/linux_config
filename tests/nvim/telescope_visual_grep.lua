-- Run from the repository root:
-- nvim --headless -u NONE -l tests/nvim/telescope_visual_grep.lua
vim.g.mapleader = " "
local plugin = dofile("dotfiles/nvim/lua/plugins/telescope.lua")[1]

local normal, visual
for _, key in ipairs(plugin.keys) do
	if key[1] == "<leader>fg" then
		if key.mode == "x" then
			visual = key[2]
		else
			normal = key[2]
		end
	end
end
assert(normal == "<cmd>Telescope live_grep<cr>", "Normal Space f g must remain unchanged")
assert(type(visual) == "function", "Visual Space f g callback missing")

local captures = {}
package.loaded["telescope.builtin"] = {
	live_grep = function(opts)
		table.insert(captures, opts)
	end,
}

-- Select a literal containing regex punctuation.
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "foo.bar other" })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
vim.fn.setreg('"', "keep-internal")
vim.fn.setreg("+", "keep-system")
vim.cmd("normal! v6l")
assert(vim.fn.mode() == "v", "Expected active characterwise Visual mode")
visual()
assert(#captures == 1, "Visual search did not launch")
assert(captures[1].default_text == "foo.bar", "Wrong visual selection")
assert(vim.deep_equal(captures[1].additional_args(), { "--fixed-strings" }), "Search must be literal")
assert(vim.fn.getreg('"') == "keep-internal", "Unnamed register was modified")
assert(vim.fn.getreg("+") == "keep-system", "System clipboard was modified")

print("Telescope visual live grep: OK")
vim.cmd.quitall({ bang = true })
