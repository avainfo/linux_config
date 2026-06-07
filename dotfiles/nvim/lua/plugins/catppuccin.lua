return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000, -- Load first
		lazy = false, -- Load immediately (not lazy)
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- latte, frappe, macchiato, mocha
				background = {
					light = "latte",
					dark = "mocha",
				},
				transparent_background = false,
				term_colors = true,
				integrations = {
					cmp = true,
					treesitter = true,
					telescope = {
						enabled = true,
					},
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
						},
					},
				},
			})

			-- Apply the colorscheme
			vim.cmd("colorscheme catppuccin")
			-- Custom background
			vim.cmd("hi Normal guibg=#1a1a1a")
		end,
	},
}
