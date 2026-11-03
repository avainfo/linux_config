-- Run from the repository root after cloning nvim-cmp to CMP_SOURCE_DIR:
-- nvim --headless -u NONE -l tests/nvim/cmp_fuzzy_matching.lua
local cmp_path = vim.env.CMP_SOURCE_DIR
assert(cmp_path and vim.fn.isdirectory(cmp_path) == 1, "CMP_SOURCE_DIR must contain nvim-cmp")
vim.opt.runtimepath:prepend(cmp_path)

local file = table.concat(vim.fn.readfile("dotfiles/nvim/lua/plugins/cmp.lua"), "\n")
assert(file:find("disallow_partial_fuzzy_matching = false", 1, true), "Partial fuzzy matching is disabled")
assert(file:find("disallow_symbol_nonprefix_matching = false", 1, true), "Symbol fuzzy matching is disabled")

local matcher = require("cmp.matcher")
local options = {
	disallow_fuzzy_matching = false,
	disallow_fullfuzzy_matching = false,
	disallow_partial_fuzzy_matching = false,
	disallow_partial_matching = false,
	disallow_prefix_unmatching = false,
	disallow_symbol_nonprefix_matching = false,
}
local score = matcher.match("bpf_find_", "bpf_object__find_map_by_name", options)
assert(score > 0, "snake_case fuzzy matching did not match bpf_find_ with bpf_object__find_map_by_name")

print("nvim-cmp snake_case fuzzy matching checks passed")
vim.cmd.quitall({ bang = true })
