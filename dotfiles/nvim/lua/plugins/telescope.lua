return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Telescope live grep" },
			{
				"<leader>fg",
				function()
					-- Read the active Visual selection without touching any register.
					local selection = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), {
						type = vim.fn.mode(),
					})
					if #selection ~= 1 or selection[1] == "" then
						vim.notify("Select text on one line to search the project", vim.log.levels.WARN)
						return
					end
					require("telescope.builtin").live_grep({
						default_text = selection[1],
						-- A selection is literal text, not a ripgrep regular expression.
						additional_args = function()
							return { "--fixed-strings" }
						end,
					})
				end,
				mode = "x",
				desc = "Telescope grep visual selection (literal)",
			},
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
