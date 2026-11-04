-- Regression test for refactoring.nvim C Tree-sitter queries.
-- Run from repository root with REFACTOR_PLUGIN_DIR and ASYNC_PLUGIN_DIR set.
local root = vim.fn.getcwd()
vim.opt.runtimepath:prepend(root .. "/dotfiles/nvim")
vim.opt.runtimepath:append(assert(vim.env.REFACTOR_PLUGIN_DIR, "REFACTOR_PLUGIN_DIR is required"))
vim.opt.runtimepath:append(assert(vim.env.ASYNC_PLUGIN_DIR, "ASYNC_PLUGIN_DIR is required"))

-- Register the custom Tree-sitter directives used by refactoring.nvim.
vim.cmd("runtime plugin/ts.lua")

local files = vim.treesitter.query.get_files("c", "refactor_reference")
assert(#files > 0, "No C refactor_reference query found")
assert(files[1]:find("dotfiles/nvim/queries/c/refactor_reference.scm", 1, true),
	"Expected local override first, got " .. vim.inspect(files))

local names = {
	"refactor_reference",
	"refactor_scope",
	"refactor_variable",
	"refactor_input_function",
	"refactor_output_function",
	"refactor_output_statement",
	"refactor_comment",
}
for _, name in ipairs(names) do
	local ok, query = pcall(vim.treesitter.query.get, "c", name)
	assert(ok, string.format("C query %s failed to compile: %s", name, tostring(query)))
	assert(query, "C query missing: " .. name)
end

vim.api.nvim_buf_set_lines(0, 0, -1, false, {
	"struct Process { int pid; };",
	"void print_process(struct Process *process) {",
	'    printf("Process: %d\\n", process->pid);',
	"    int status = process->pid;",
	"    if (status) printf(\"Running\\n\");",
	"}",
})
vim.bo.filetype = "c"
local parser = vim.treesitter.get_parser(0, "c")
local trees = parser:parse()
local query = assert(vim.treesitter.query.get("c", "refactor_reference"))
local matches = 0
for _ in query:iter_matches(trees[1]:root(), 0) do
	matches = matches + 1
end
assert(matches > 0, "C refactoring query compiled but found no references in sample")

-- Exercise the actual :Refactor extract_func workflow against a C buffer.
-- This catches query failures that a plugin-loading smoke test cannot detect.
vim.api.nvim_buf_set_lines(0, 0, -1, false, {
	"void render(void) {",
	'    puts("first");',
	'    puts("second");',
	"}",
})
vim.bo.filetype = "c"
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.api.nvim_win_set_cursor(0, { 2, 4 })
vim.cmd("runtime plugin/command.lua")
local keys = vim.api.nvim_replace_termcodes("Vj:Refactor extract_func print_block<CR>", true, false, true)
vim.api.nvim_feedkeys(keys, "xt", false)

local success = vim.wait(4000, function()
	local lines = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	return lines:find("void print_block(", 1, true) ~= nil
end, 20)
local changed = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
assert(success, "Extract Function did not create a C function:\n" .. changed)
assert(changed:find("print_block();", 1, true), "Extract Function did not replace the selected body with a call:\n" .. changed)
print("C Tree-sitter queries and real extract_func refactoring succeeded")
vim.cmd.quitall({ bang = true })
