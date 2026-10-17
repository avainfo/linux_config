local languages = {
	"bash",
	"c",
	"cpp",
	"doxygen",
	"json",
	"javascript",
	"jsdoc",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"rust",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			vim.treesitter.language.register("yaml", "yaml.docker-compose")

			require("nvim-treesitter").install(languages)

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("AvaTreesitter", { clear = true }),
				callback = function(args)
					if vim.bo[args.buf].buftype == "" then
						pcall(vim.treesitter.start, args.buf)
					end
				end,
			})
		end,
	},
}
