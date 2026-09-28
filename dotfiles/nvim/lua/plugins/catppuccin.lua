return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
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
				custom_highlights = function(colors)
					return {
						Normal = { bg = "#1a1a1a" },
						NormStatusOn = { fg = colors.green, bold = true },
						NormStatusOff = { fg = colors.red, bold = true },
						CmpNormal = { bg = "#242438" },
						CmpBorder = { fg = "#7c6f9f" },
						CmpDocNormal = { bg = "#1e1e2e" },
						CmpDocBorder = { fg = "#585b70" },
						CmpSel = { bg = "#313244", bold = true },
					}
				end,
			})

			vim.cmd("colorscheme catppuccin")
		end,
	},
}
