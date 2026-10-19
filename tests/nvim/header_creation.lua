-- Run from the repository root:
-- nvim --headless -u NONE -l tests/nvim/header_creation.lua

vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/dotfiles/nvim")
local header = require("ava.header")
header.setup()

local tmpdir = vim.fn.tempname()
vim.fn.mkdir(tmpdir, "p")

local function assert_contains(value, needle)
	assert(value:find(needle, 1, true), ("Missing %q in %q"):format(needle, value))
end

local function buffer_text(bufnr)
	return table.concat(vim.api.nvim_buf_get_lines(bufnr or 0, 0, -1, false), "\n")
end

local function reset()
	vim.cmd("enew!")
end

local function new_file(name)
	reset()
	vim.cmd.edit(vim.fn.fnameescape(tmpdir .. "/" .. name))
	return buffer_text()
end

local c = new_file("new.c")
assert_contains(c, "Ava Info Conseils")
assert_contains(c, "SPDX-License-Identifier: MIT")
assert_contains(c, "/*")
assert(vim.api.nvim_buf_get_lines(0, -2, -1, false)[1] == "", "Expected a trailing empty line")
assert(select(2, c:gsub("SPDX%-License%-Identifier: MIT", "")) == 1, "Duplicate header on a new file")
vim.cmd.write()
reset()
vim.cmd.edit(vim.fn.fnameescape(tmpdir .. "/new.c"))
assert(buffer_text() == c, "Existing files must not gain another header")

vim.fn.writefile({}, tmpdir .. "/existing_empty.h")
reset()
vim.cmd.edit(vim.fn.fnameescape(tmpdir .. "/existing_empty.h"))
assert(buffer_text() == "", "Do not modify existing empty files")

vim.fn.writefile({ "int answer = 42;" }, tmpdir .. "/existing.c")
reset()
vim.cmd.edit(vim.fn.fnameescape(tmpdir .. "/existing.c"))
assert(buffer_text() == "int answer = 42;", "Do not modify existing content")

for _, ext in ipairs({ "h", "cc", "hh", "cpp", "hpp", "tpp", "ipp", "cxx", "go", "rs", "java", "kt", "kts", "js", "ts", "lua", "py", "asm", "tex", "ml", "mli", "mll", "mly", "vim", "f", "for", "f90", "f95", "f03", "el" }) do
	local out = new_file("demo." .. ext)
	assert_contains(out, "SPDX-License-Identifier: MIT")
end

local php = new_file("page.php")
assert(php:sub(1, 5) == "<?php", "PHP must open its code block before the comment")
assert_contains(php, "SPDX-License-Identifier: MIT")

local xml = new_file("page.xml")
assert(xml:sub(1, 5) == "<?xml", "XML declaration must precede the comment")
assert_contains(xml, "SPDX-License-Identifier: MIT")

local html = new_file("page.html")
assert(html:sub(1, 15) == "<!DOCTYPE html>", "HTML doctype must precede the comment")
assert_contains(html, "SPDX-License-Identifier: MIT")

assert_contains(new_file(".vimrc"), "SPDX-License-Identifier: MIT")
assert_contains(new_file(".emacs"), "SPDX-License-Identifier: MIT")
assert_contains(new_file("page.htm"), "SPDX-License-Identifier: MIT")
assert(new_file("view.tsx") == "", "Unsupported TSX must remain unchanged")
assert(new_file("view.jsx") == "", "Unsupported JSX must remain unchanged")

reset()
vim.cmd.split(vim.fn.fnameescape(tmpdir .. "/from_split.cpp"))
assert_contains(buffer_text(), "SPDX-License-Identifier: MIT")
vim.cmd.close()
reset()
vim.cmd.vsplit(vim.fn.fnameescape(tmpdir .. "/from_vsplit.h"))
assert_contains(buffer_text(), "SPDX-License-Identifier: MIT")
vim.cmd.close()

assert(new_file("README.md") == "", "Unsupported file extensions must remain untouched")

local oilfile = tmpdir .. "/oil_created.c"
vim.fn.writefile({}, oilfile)
vim.api.nvim_exec_autocmds("User", {
	pattern = "OilActionsPost",
	data = { actions = { { type = "create", entry_type = "file", url = "oil://" .. oilfile } } },
})
reset()
vim.cmd.edit(vim.fn.fnameescape(oilfile))
assert_contains(buffer_text(), "SPDX-License-Identifier: MIT")
local oil_content = buffer_text()
vim.api.nvim_exec_autocmds("BufReadPost", { buffer = 0 })
assert(buffer_text() == oil_content, "Oil must not insert duplicate headers")

local oldempty = tmpdir .. "/other_empty.c"
vim.fn.writefile({}, oldempty)
reset()
vim.cmd.edit(vim.fn.fnameescape(oldempty))
assert(buffer_text() == "", "Untracked empty files must remain empty")

local oil_failed = tmpdir .. "/oil_failed.c"
vim.fn.writefile({}, oil_failed)
vim.api.nvim_exec_autocmds("User", {
	pattern = "OilActionsPost",
	data = { err = "operation failed", actions = { { type = "create", entry_type = "file", url = "oil://" .. oil_failed } } },
})
reset()
vim.cmd.edit(vim.fn.fnameescape(oil_failed))
assert(buffer_text() == "", "Failed Oil actions must not insert a header")

local remote = "oil-ssh://example/code/new.hpp"
local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(buf, remote)
vim.bo[buf].buftype = "acwrite"
vim.bo[buf].modified = false
vim.api.nvim_exec_autocmds("User", {
	pattern = "OilActionsPost",
	data = { actions = { { type = "create", entry_type = "file", url = remote } } },
})
vim.api.nvim_exec_autocmds("BufReadPost", { buffer = buf })
assert_contains(buffer_text(buf), "SPDX-License-Identifier: MIT")

reset()
vim.cmd.file(vim.fn.fnameescape(tmpdir .. "/renamed_new.kt"))
assert_contains(buffer_text(), "SPDX-License-Identifier: MIT")

vim.fn.delete(tmpdir, "rf")
print("MIT header creation checks passed")
vim.cmd.quitall({ bang = true })
