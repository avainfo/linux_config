vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.timeout = true
vim.opt.timeoutlen = 500

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.expandtab = false
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.textwidth = 120

vim.opt.list = true
vim.opt.listchars = {
	tab = "»·",
	trail = "·",
}

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 5
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"

local undo_dir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undo_dir, "p")
vim.opt.undodir = undo_dir
vim.opt.undofile = true
