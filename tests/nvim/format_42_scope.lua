-- Validate Space fm behavior without installing external formatters.
-- Run from repository root: nvim --headless -u NONE -l tests/nvim/format_42_scope.lua
vim.g.mapleader = " "

local calls = {}
local notifications = {}
local registered

package.preload["conform"] = function()
	return {
		setup = function(opts)
			registered = opts
		end,
		format = function(opts)
			table.insert(calls, opts)
		end,
	}
end

vim.notify = function(msg)
	table.insert(notifications, msg)
end

local plugin = dofile("dotfiles/nvim/lua/plugins/format.lua")[1]
plugin.config()

assert(registered, "Conform setup was not called")
assert(registered.formatters_by_ft.c[1] == "clang-format", "Non-42 C formatter changed unexpectedly")

local keymap = vim.fn.maparg("<Space>fm", "n", false, true)
assert(type(keymap.callback) == "function", "Space fm callback is not registered")

local function verify(file, expected_calls)
	local bufnr = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(bufnr, file)
	vim.api.nvim_set_current_buf(bufnr)
	keymap.callback()
	assert(#calls == expected_calls,
		string.format("Wrong formatting count for %s: expected %d, got %d", file, expected_calls, #calls))
end

verify("/home/ava/code/42/milestone3/Codexion/src/main.c", 0)
verify("/home/ava/code/42/milestone3/Codexion/include/codexion.h", 0)
verify("/home/ava/code/42/python/exercise.py", 0)
verify("/home/ava/Documents/42/libft/ft_atoi.c", 0)
verify("/home/ava/code/42-other/main.c", 1)
verify("/home/ava/code/personal/AVA-CausalTrace/agent/main.c", 2)
assert(#notifications == 4, "Expected notifications only for 42 files")
assert(calls[1].lsp_fallback == true, "Original formatter options changed unexpectedly")

print("Space fm is disabled in 42 projects and unchanged outside 42")
vim.cmd.quitall({ bang = true })
