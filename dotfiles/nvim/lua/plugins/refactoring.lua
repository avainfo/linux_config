return {
	{
		"ThePrimeagen/refactoring.nvim",
		-- This tested upstream revision supports Neovim 0.11; latest requires 0.12.
		commit = "3c87abd5b1786cb0cf4810ac435211fac52a4a35",
		dependencies = {
			"lewis6991/async.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			-- Visual selection -> Space r e -> name the new function -> Enter.
			{ "<leader>re", ":Refactor extract_func ", mode = "x", desc = "Extract selected code to function" },
		},
	},
}
