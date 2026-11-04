-- Smoke-test the pinned refactoring.nvim integration on Neovim 0.11.7.
-- CI supplies REFACTOR_PLUGIN_DIR and ASYNC_PLUGIN_DIR.
local spec = dofile("dotfiles/nvim/lua/plugins/refactoring.lua")[1]
assert(spec.commit == "3c87abd5b1786cb0cf4810ac435211fac52a4a35")
assert(spec.keys[1][1] == "<leader>re" and spec.keys[1].mode == "x")
assert(spec.keys[1][2] == ":Refactor extract_func ")

local async_dir = assert(vim.env.ASYNC_PLUGIN_DIR, "Set ASYNC_PLUGIN_DIR")
local refactor_dir = assert(vim.env.REFACTOR_PLUGIN_DIR, "Set REFACTOR_PLUGIN_DIR")
vim.opt.runtimepath:prepend(async_dir)
vim.opt.runtimepath:prepend(refactor_dir)

vim.cmd("runtime plugin/command.lua")
assert(vim.fn.exists(":Refactor") == 2, ":Refactor command was not registered")

local ok, plugin = pcall(require, "refactoring")
assert(ok, tostring(plugin))
assert(type(plugin.extract_func) == "function")
assert(plugin.extract_func({ input = { "print_process" } }) == "g@")

print("Neovim 0.11 refactoring plugin integration smoke-test passed")
vim.cmd.quitall({ bang = true })
