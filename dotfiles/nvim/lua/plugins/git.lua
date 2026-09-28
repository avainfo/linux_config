return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			current_line_blame = false,
			current_line_blame_opts = {
				delay = 800,
				virt_text_pos = "eol",
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, lhs, rhs, desc, extra)
					local opts = {
						buffer = bufnr,
						desc = desc,
					}

					if extra then
						opts = vim.tbl_extend("force", opts, extra)
					end

					vim.keymap.set(mode, lhs, rhs, opts)
				end

				map("n", "]h", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(gs.next_hunk)
					return "<Ignore>"
				end, "Next hunk", { expr = true })

				map("n", "[h", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(gs.prev_hunk)
					return "<Ignore>"
				end, "Prev hunk", { expr = true })

				map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
				map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage hunk (visual)")
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset hunk (visual)")

				map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
				map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
				map("n", "<leader>hd", gs.diffthis, "Diff this")
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, "Diff this (last commit)")

				map("n", "<leader>hb", gs.blame_line, "Blame line")
				map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle blame")

				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
			end,
		},
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
			{ "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", desc = "LazyGit (current file)" },
			{ "<leader>gl", "<cmd>LazyGitFilter<CR>", desc = "LazyGit log" },
		},
	},
	{
		"sindrets/diffview.nvim",
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewFileHistory",
		},
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview open" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview file history" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview repo history" },
			{ "<leader>gx", "<cmd>DiffviewClose<CR>", desc = "Diffview close" },
		},
		opts = {
			enhanced_diff_hl = true,
			view = {
				default = {
					layout = "diff2_horizontal",
				},
				merge_tool = {
					layout = "diff3_horizontal",
					disable_diagnostics = true,
				},
			},
		},
	},
}
