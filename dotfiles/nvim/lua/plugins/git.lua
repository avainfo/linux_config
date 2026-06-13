return {

	-- ─────────────────────────────────────────────────────────────
	-- gitsigns: gutter signs + hunk operations
	-- ─────────────────────────────────────────────────────────────
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

				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				-- Hunk navigation
				map("n", "]h", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(gs.next_hunk)
					return "<Ignore>"
				end, "Next hunk")

				map("n", "[h", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(gs.prev_hunk)
					return "<Ignore>"
				end, "Prev hunk")

				-- Hunk operations
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

				-- Blame
				map("n", "<leader>hb", gs.blame_line, "Blame line")
				map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle blame")

				-- Text objects: ih = inner hunk
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
			end,
		},
	},

	-- ─────────────────────────────────────────────────────────────
	-- lazygit: full git interface in a floating window
	-- ─────────────────────────────────────────────────────────────
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

	-- ─────────────────────────────────────────────────────────────
	-- diffview: clean diff and history explorer
	-- ─────────────────────────────────────────────────────────────
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

	-- ─────────────────────────────────────────────────────────────
	-- octo.nvim: GitHub PRs and issues inside Neovim
	-- Uncomment if you do regular PR reviews
	-- Requires: gh CLI installed and authenticated (gh auth login)
	-- ─────────────────────────────────────────────────────────────
	-- {
	--   "pwntester/octo.nvim",
	--   cmd = "Octo",
	--   dependencies = {
	--     "nvim-lua/plenary.nvim",
	--     "nvim-telescope/telescope.nvim",
	--     "nvim-tree/nvim-web-devicons",
	--   },
	--   opts = {
	--     enable_builtin = true,
	--   },
	--   keys = {
	--     { "<leader>gp", "<cmd>Octo pr list<CR>",    desc = "Octo PR list" },
	--     { "<leader>gi", "<cmd>Octo issue list<CR>", desc = "Octo issue list" },
	--   },
	-- },
}
