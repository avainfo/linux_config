-- Smoke-test Oil-only five-entry Shift+Arrow navigation.
-- Run from repo root: nvim --headless -u NONE -l tests/nvim/oil_shift_navigation.lua
local plugin = dofile("dotfiles/nvim/lua/plugins/oil.lua")
local opts = plugin.opts()
local up = assert(opts.keymaps["<S-Up>"], "Oil Shift+Up mapping missing")
local down = assert(opts.keymaps["<S-Down>"], "Oil Shift+Down mapping missing")
assert(type(up.callback) == "function" and type(down.callback) == "function")

-- Mappings belong to Oil's buffer-local keymaps, not the global editor.
assert(vim.fn.maparg("<S-Up>", "n") == "", "Unexpected global Shift+Up mapping")
assert(vim.fn.maparg("<S-Down>", "n") == "", "Unexpected global Shift+Down mapping")

local lines = {}
for i = 1, 30 do
	lines[i] = ("entry-%02d"):format(i)
end
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
vim.api.nvim_win_set_cursor(0, { 10, 0 })
down.callback()
assert(vim.api.nvim_win_get_cursor(0)[1] == 15, "Shift+Down must move five lines")
up.callback()
assert(vim.api.nvim_win_get_cursor(0)[1] == 10, "Shift+Up must move five lines")

print("Oil Shift+Arrow navigation: five entries, no global keymap")
vim.cmd.quitall({ bang = true })
