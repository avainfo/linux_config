return {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
	config = function()
	require("nvim-surround").setup({})

	local map = vim.keymap.set
	local opts = { remap = true, silent = true }

	-- Normal mode: wrap current word
	map("n", '<leader>a"', 'ysiw"', vim.tbl_extend("force", opts, {
		desc = "Wrap word with double quotes",
	}))

	map("n", "<leader>a'", "ysiw'", vim.tbl_extend("force", opts, {
		desc = "Wrap word with single quotes",
	}))

	map("n", "<leader>ap", "ysiw)", vim.tbl_extend("force", opts, {
		desc = "Wrap word with parentheses",
	}))

	map("n", "<leader>ab", "ysiw]", vim.tbl_extend("force", opts, {
		desc = "Wrap word with brackets",
	}))

	map("n", "<leader>aB", "ysiw}", vim.tbl_extend("force", opts, {
		desc = "Wrap word with braces",
	}))

	-- Visual mode: wrap selected text
	map("x", '<leader>a"', 'S"', vim.tbl_extend("force", opts, {
		desc = "Wrap selection with double quotes",
	}))

	map("x", "<leader>a'", "S'", vim.tbl_extend("force", opts, {
		desc = "Wrap selection with single quotes",
	}))

	map("x", "<leader>ap", "S)", vim.tbl_extend("force", opts, {
		desc = "Wrap selection with parentheses",
	}))

	map("x", "<leader>ab", "S]", vim.tbl_extend("force", opts, {
		desc = "Wrap selection with brackets",
	}))

	map("x", "<leader>aB", "S}", vim.tbl_extend("force", opts, {
		desc = "Wrap selection with braces",
	}))
	end,
}
