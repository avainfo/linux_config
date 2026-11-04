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

print("C refactoring queries compile and match C source successfully")
vim.cmd.quitall({ bang = true })
