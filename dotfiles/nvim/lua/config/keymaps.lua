vim.keymap.set("n", "<F2>", "<cmd>write<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<F2>", "<Esc><cmd>write<CR>i", { noremap = true, silent = true })

vim.keymap.set("n", "<C-Left>", "b", { noremap = true })
vim.keymap.set("n", "<C-Right>", "w", { noremap = true })
vim.keymap.set("i", "<C-Left>", "<C-o>b", { noremap = true })
vim.keymap.set("i", "<C-Right>", "<C-o>w", { noremap = true })

vim.keymap.set("n", "<C-Del>", "dw", { noremap = true, silent = true })
vim.keymap.set("i", "<C-Del>", "<C-o>dw", { noremap = true, silent = true })
vim.keymap.set("n", "<C-h>", "db", { noremap = true, silent = true })
vim.keymap.set("i", "<C-h>", "<C-w>", { noremap = true, silent = true })

-- Copy to the system clipboard without changing Neovim's unnamed register.
vim.keymap.set("x", "<leader>y", function()
	local mode = vim.fn.mode()
	local selection = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
	vim.fn.setreg("+", selection, mode)
	return "<Esc>`<"
end, { expr = true, desc = "Copy selection to system clipboard" })

vim.keymap.set("n", "<leader>y", function()
	vim.fn.setreg("+", vim.api.nvim_get_current_line(), "V")
end, { desc = "Copy line to system clipboard" })
local headers = require("ava.header")

vim.keymap.set("n", "<F1>f", headers.stdheader, { silent = true, desc = "Header: 42 stdheader" })
vim.keymap.set("n", "<F1>m", headers.mit_header, { silent = true, desc = "Header: MIT" })
vim.keymap.set("n", "<F1>g", headers.gpl_header, { silent = true, desc = "Header: GPL-2.0-only" })
vim.keymap.set("n", "<F1>a", headers.apache_header, { silent = true, desc = "Header: Apache 2.0" })
vim.keymap.set("n", "<F1>p", headers.private_header, { silent = true, desc = "Header: proprietary/private" })

vim.keymap.set("n", "<Space>n", "<cmd>write<CR>", { desc = "Save and run Norminette" })

-- Toggle the Quickfix window in the current tab.
vim.keymap.set("n", "<leader>Q", function()
	local info = vim.fn.getqflist({ winid = 0 })
	if info.winid and info.winid ~= 0 then
		vim.cmd("cclose")
	else
		vim.cmd("copen")
	end
end, { desc = "Toggle Quickfix list", silent = true })

vim.keymap.set("n", "<Space>s", function()
	vim.diagnostic.open_float(nil, { focus = true })
end, { desc = "Show diagnostics at cursor" })

local cp = require("ava.cp")

vim.keymap.set("n", "<F5>", cp.run, { desc = "CP: compile & run" })
vim.keymap.set("n", "<F6>", cp.run_with_input, { desc = "CP: run with input.txt" })
vim.keymap.set("n", "<F7>", cp.build, { desc = "CP: build only" })
vim.keymap.set("n", "<F8>", cp.open_input, { desc = "CP: open input.txt" })
vim.keymap.set("n", "<Space>ct", cp.load_template, { desc = "CP: load template" })

vim.keymap.set("t", "<C-q>", "<C-\\><C-n>", { noremap = true, desc = "Terminal: normal mode" })

vim.keymap.set("n", "<leader>cp", function()
	vim.cmd("write")
	vim.cmd("botright split")
	vim.cmd("resize 12")
	vim.cmd("terminal checkp **/*.py")
end, { desc = "Run checkp on Python files" })
