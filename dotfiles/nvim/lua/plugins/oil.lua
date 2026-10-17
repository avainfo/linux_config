return {
	"stevearc/oil.nvim",
	branch = "nvim-0.9",
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
