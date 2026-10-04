local filetypes = vim.api.nvim_create_augroup("AvaFiletypes", { clear = true })


vim.filetype.add({
	filename = {
		["compose.yml"] = "yaml.docker-compose",
		["compose.yaml"] = "yaml.docker-compose",
		["docker-compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
	},
	pattern = {
		[".*/compose%..*%.ya?ml"] = "yaml.docker-compose",
		[".*/docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	group = filetypes,
	pattern = "python",
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.cindent = false
		vim.opt_local.autoindent = true
		vim.opt_local.smartindent = true
		vim.b.editorconfig = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = filetypes,
	pattern = { "c", "cpp" },
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.cindent = true

		if vim.bo.modifiable then
			vim.opt_local.comments = "sl:/*,mb:\\ *,elx:\\ *"
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = filetypes,
	pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	callback = function()
		vim.b.editorconfig = false
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.cindent = false
		vim.opt_local.autoindent = true
		vim.opt_local.smartindent = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = filetypes,
	pattern = { "yaml", "yaml.docker-compose" },
	callback = function()
		vim.b.editorconfig = false
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.cindent = false
		vim.opt_local.autoindent = true
		vim.opt_local.smartindent = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = filetypes,
	pattern = "gitcommit",
	callback = function()
		vim.opt_local.textwidth = 72
		vim.opt_local.colorcolumn = "51,73"
		vim.opt_local.spell = true
		vim.opt_local.wrap = true
	end,
})
