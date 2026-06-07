return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		lazy = false,
		config = function()
			vim.treesitter.language.register("markdown", "cmp_docs")

			require("render-markdown").setup({
				file_types = { "markdown", "Avante", "cmp_docs" },

				render_modes = { "n", "i", "c" },

				hover = {
					enabled = true,
				},
			})
		end,
	},
}
