return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Telescope live grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Telescope buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Telescope help tags" },
			{
				"<leader>fa",
				function()
					require("telescope.builtin").find_files({ hidden = true })
				end,
				desc = "Telescope find files (including hidden)",
			},
			{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Telescope document symbols (LSP)" },
			{
				"<leader>fw",
				"<cmd>Telescope lsp_dynamic_workspace_symbols<CR>",
				desc = "Telescope workspace symbols (LSP)",
			},
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
				},
			})
		end,
	},
}
