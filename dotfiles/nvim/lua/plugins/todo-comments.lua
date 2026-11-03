return {
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPost", "BufNewFile" },
		cmd = { "TodoQuickFix", "TodoLocList", "TodoTelescope" },
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next TODO/comment marker",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous TODO/comment marker",
			},
			{ "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs in project" },
		},
		opts = {
			signs = true,
			-- Default markers: TODO, FIX/FIXME/BUG, HACK, WARN, PERF, NOTE, TEST.
			keywords = {
				SECURITY = { icon = " ", color = "error", alt = { "VULN" } },
			},
			highlight = {
				comments_only = true,
				keyword = "wide",
				after = "fg",
			},
		},
	},
}
