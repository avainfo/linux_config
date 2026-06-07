return {
	{
		"danymat/neogen",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("neogen").setup({
				enabled = true,
				languages = {
					c = { template = { annotation_convention = "doxygen" } },
					cpp = { template = { annotation_convention = "doxygen" } },
					python = { template = { annotation_convention = "google_docstrings" } },
				},
			})

			vim.keymap.set("n", "<leader>nd", function()
				require("neogen").generate()
			end, { desc = "Generate docstring" })
		end,
	},
}
