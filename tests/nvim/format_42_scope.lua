-- Run from repository root:
-- nvim --headless -u NONE -l tests/nvim/format_42_scope.lua
vim.g.mapleader = " "
package.path = "dotfiles/nvim/lua/?.lua;dotfiles/nvim/lua/?/init.lua;" .. package.path

local policy = require("ava.format_42")
local calls, notifications = {}, {}
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

assert(policy.is_42_path("/home/ava/code/42/milestone3/example.py"))
assert(policy.is_42_path("/home/ava/Documents/42/exercise.py"))
for _, path in ipairs({
	"/home/ava/code/42-backup/exercise.py",
	"/home/ava/code/42-other/exercise.py",
	"/home/ava/code/my42/exercise.py",
	"/home/ava/code/42ish/42_file.py",
}) do
	assert(not policy.is_42_path(path), "False positive: " .. path)
end

local plugin = dofile("dotfiles/nvim/lua/plugins/format.lua")[1]
plugin.config()
assert(registered and registered.formatters, "Conform setup missing")
assert(registered.formatters.ruff_42_format.inherit == "ruff_format", "Must reuse Ruff formatter")
assert(registered.format_on_save(1) == nil, "No Python format-on-save expected")

local function buffer(file, ft)
	local bufnr = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(bufnr, file)
	vim.api.nvim_set_current_buf(bufnr)
	vim.bo[bufnr].filetype = ft
	return bufnr
end

local function expect_list(actual, expected, label)
	assert(#actual == #expected, label .. ": unexpected formatter count")
	for i, item in ipairs(expected) do
		assert(actual[i] == item, label .. ": wrong formatter at " .. i)
	end
end

local within = buffer("/home/ava/code/42/milestone3/CallMeMaybe/main.py", "python")
local scope = registered.formatters_by_ft.python(within)
expect_list(scope, { "ruff_42_format" }, "42 Python")
assert(scope.lsp_format == "never", "42 Python must not use LSP")

local outside = buffer("/home/ava/code/personal/main.py", "python")
expect_list(registered.formatters_by_ft.python(outside),
	{ "ruff_fix", "ruff_organize_imports", "ruff_format" }, "normal Python")

for _, ft in ipairs({ "c", "cpp" }) do
	local b42 = buffer("/home/ava/code/42/milestone3/main." .. ft, ft)
	expect_list(registered.formatters_by_ft[ft](b42), {}, "42 " .. ft)
	local bnormal = buffer("/home/ava/code/personal/main." .. ft, ft)
	expect_list(registered.formatters_by_ft[ft](bnormal), { "clang-format" }, "normal " .. ft)
end

local global_map = vim.fn.maparg("<Space>fm", "n", false, true)
assert(global_map.callback == policy.format_current_file, "Space fm mapping changed")

local function verify(file, ft, expected_calls, expected_notifications, expected_lsp)
	local bufnr = buffer(file, ft)
	policy.format_current_file()
	assert(#calls == expected_calls, file .. ": wrong formatting count")
	assert(#notifications == expected_notifications, file .. ": wrong notification count")
	if expected_lsp then
		assert(calls[#calls].lsp_format == expected_lsp, file .. ": wrong LSP behavior")
	end
	return bufnr
end

verify("/home/ava/code/42/milestone3/Codexion/main.c", "c", 0, 1)
verify("/home/ava/code/42/milestone3/Codexion/main.h", "c", 0, 2)
verify("/home/ava/code/42/milestone3/CallMeMaybe/main.py", "python", 1, 2, "never")
verify("/home/ava/Documents/42/exercise.py", "python", 2, 2, "never")
verify("/home/ava/code/42/exercise.cpp", "cpp", 2, 3)
verify("/home/ava/code/42-backup/main.py", "python", 3, 3)
assert(calls[#calls].lsp_fallback == true, "Outside-42 fallback must remain")
verify("/home/ava/code/personal/main.c", "c", 4, 3)
verify("/home/ava/code/personal/main.py", "python", 5, 3)

local lsp_buf = buffer("/home/ava/code/42/something.py", "python")
require("config.lsp").on_attach(nil, lsp_buf)
local local_map = vim.fn.maparg("<Space>fm", "n", false, true)
assert(local_map.buffer == 1, "LSP buffer must register local longer mapping")
assert(local_map.callback == policy.format_current_file, "LSP shadowed Space fm")
assert(vim.fn.maparg("<Space>f", "n", false, true).buffer == 1, "LSP format shortcut lost")
local_map.callback()
assert(#calls == 6 and calls[#calls].lsp_format == "never", "LSP map did not select safe formatter")

-- Ruff config lookup must preserve project line lengths, including nested configs.
local temp = vim.fn.tempname()
local project = temp .. "/42/milestone3"
vim.fn.mkdir(project .. "/src", "p")
local filename = project .. "/src/main.py"
local function args()
	return policy.ruff_prepend_args(filename)
end
expect_list(args(), { "--config", "line-length = 79" }, "42 default")
vim.fn.writefile({ "[project]", 'name = "exercise"' }, project .. "/pyproject.toml")
expect_list(args(), { "--config", "line-length = 79" }, "Unrelated project metadata")
vim.fn.writefile({ "[tool.ruff]", "line-length = 120" }, project .. "/pyproject.toml")
expect_list(args(), {}, "pyproject Ruff settings")
vim.fn.writefile({ "[tool.ruff.format]", 'quote-style = "single"' }, project .. "/pyproject.toml")
expect_list(args(), {}, "Nested Ruff settings")
vim.fn.delete(project .. "/pyproject.toml")
vim.fn.writefile({ "line-length = 100" }, project .. "/ruff.toml")
expect_list(args(), {}, "ruff.toml")
vim.fn.delete(project .. "/ruff.toml")
vim.fn.writefile({ "line-length = 100" }, project .. "/.ruff.toml")
expect_list(args(), {}, ".ruff.toml")
vim.fn.delete(project .. "/.ruff.toml")

-- An actual Ruff invocation verifies the default and pyproject precedence.
assert(vim.fn.executable("ruff") == 1, "Ruff required for integration test")
local source = "value = function_call(first_argument, second_argument, third_argument, fourth_argument, fifth_argument)\n"
local function format_python()
	local command = { "ruff" }
	vim.list_extend(command, args())
	vim.list_extend(command, { "format", "--stdin-filename", filename, "-" })
	local output = vim.fn.system(command, source)
	assert(vim.v.shell_error == 0, "Ruff failed: " .. output)
	return output
end

local pep8_output = format_python()
assert(pep8_output:find("\n    ", 1, true), "PEP 8 fallback did not wrap long code")
vim.fn.writefile({ "[tool.ruff]", "line-length = 120" }, project .. "/pyproject.toml")
local project_output = format_python()
assert(not project_output:find("\n    ", 1, true), "Project Ruff line length was overridden")
vim.fn.delete(temp, "rf")

print("42 Python Ruff formatting, LSP mapping, project settings, and C scope: OK")
vim.cmd.quitall({ bang = true })
