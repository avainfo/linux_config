return {
	"stevearc/oil.nvim",
	-- Oil should load on startup so directory buffers (nvim . / :edit dir)
	-- are handled consistently.
	lazy = false,
	keys = {
		{ "-", "<cmd>Oil<CR>", desc = "Oil: open parent directory" },
		{ "<leader>o", "<cmd>Oil<CR>", desc = "Oil: browse current file directory" },
	},
	opts = {
		default_file_explorer = true,
		view_options = {
			show_hidden = true,
		},
	},
}
