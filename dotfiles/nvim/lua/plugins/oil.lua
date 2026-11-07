return {
	"stevearc/oil.nvim",
	lazy = false,
	dependencies = {
		{ "nvim-mini/mini.icons", opts = {} },
	},
	keys = {
		{ "-", "<cmd>Oil<CR>", desc = "Oil: open parent directory" },
		{ "<leader>o", "<cmd>Oil --float<CR>", desc = "Oil: browse files in a floating window" },
	},
	opts = function()
		local details = false

		return {
			default_file_explorer = true,
			columns = { "icon", "size" },
			win_options = {
				number = false,
				relativenumber = false,
				signcolumn = "no",
				cursorline = true,
				list = false,
			},
			float = {
				padding = 2,
				max_width = 90,
				max_height = 20,
				border = "rounded",
			},
			keymaps = {
				-- Move five entries at a time in Oil, rather than scrolling a page.
				["<S-Up>"] = {
					desc = "Oil: move up 5 entries",
					callback = function()
						vim.cmd("normal! 5k")
					end,
				},
				["<S-Down>"] = {
					desc = "Oil: move down 5 entries",
					callback = function()
						vim.cmd("normal! 5j")
					end,
				},
				["gd"] = {
					desc = "Oil: toggle file details",
					callback = function()
						details = not details
						require("oil").set_columns(details and { "icon", "permissions", "size", "mtime" } or { "icon", "size" })
					end,
				},
			},
			view_options = {
				show_hidden = true,
			},
		}
	end,
}
