-- Run from the repository root:
-- nvim --headless -u NONE -l tests/nvim/gf_project_headers.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/dotfiles/nvim")
vim.cmd("filetype on")
require("config.autocmds")

local initial_cwd = vim.fn.getcwd()
local tmpdir = vim.fn.tempname()
local project = tmpdir .. "/AVA-CausalTrace"
vim.fn.mkdir(project .. "/bpf", "p")
vim.fn.mkdir(project .. "/agent", "p")
vim.fn.mkdir(project .. "/include", "p")
vim.fn.writefile({ "all:" }, project .. "/Makefile")
vim.fn.writefile({ "int value;" }, project .. "/include/events.h")
vim.fn.writefile({ '#include "events.h"', "int main(void) { return 0; }" }, project .. "/bpf/main.c")
vim.fn.writefile({ '#include "events.h"' }, project .. "/agent/main.cpp")
vim.fn.writefile({ 'print("unchanged")' }, project .. "/bpf/script.py")

local function check_header(source, dir)
    vim.cmd("enew!")
    vim.fn.chdir(dir)
    vim.cmd.edit(vim.fn.fnameescape(source))
    assert(vim.bo.filetype == "c" or vim.bo.filetype == "cpp", "Expected C/C++ FileType event")
    local include_dir = project .. "/include"
    assert(vim.fn.findfile("events.h", vim.bo.path) ~= "", "gf cannot resolve events.h: " .. vim.bo.path)
    assert(vim.bo.path:find(include_dir, 1, true), "Missing project include dir from path")
    vim.cmd("normal! gg")
    vim.fn.search("events.h")
    vim.cmd("normal! gf")
    assert(vim.api.nvim_buf_get_name(0) == include_dir .. "/events.h", "gf opened the wrong file")
end

-- From project root and nested working directories, including C++.
check_header(project .. "/bpf/main.c", project)
check_header(project .. "/bpf/main.c", project .. "/bpf")
check_header(project .. "/agent/main.cpp", project .. "/agent")

-- Non-C/C++ buffers must not be changed.
vim.cmd("enew!")
vim.cmd.edit(vim.fn.fnameescape(project .. "/bpf/script.py"))
assert(not vim.bo.path:find(project .. "/include", 1, true), "Python path unexpectedly modified")

vim.fn.chdir(initial_cwd)
vim.fn.delete(tmpdir, "rf")
print("native gf project headers checks passed")
vim.cmd.quitall({ bang = true })
