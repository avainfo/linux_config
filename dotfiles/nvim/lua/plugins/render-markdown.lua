return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        lazy = false,
		opts = {
			file_types = { "markdown", "Avante", "cmp_docs" },
			render_modes = true,
			hover = { enabled = true },
		},
		ft = { "markdown", "Avante", "cmp_docs" },
	},
}
