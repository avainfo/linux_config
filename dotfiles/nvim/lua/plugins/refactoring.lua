return {
	{
		"ThePrimeagen/refactoring.nvim",
		-- Keep compatibility with Neovim 0.11.7; current upstream requires 0.12.
		commit = "3c87abd5b1786cb0cf4810ac435211fac52a4a35",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			-- In Visual mode, select complete C/C++ statements, then type a name.
			-- :Refactor extract provides a preview before applying changes.
			{ "<leader>re", ":Refactor extract ", mode = "x", desc = "Extract selected code to function" },
		},
		opts = {
			show_success_message = true,
		},
	},
}
