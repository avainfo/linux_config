return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
					json = { "prettierd" },
					jsonc = { "prettierd" },
					javascript = { "prettierd" },
					javascriptreact = { "prettierd" },
					typescript = { "prettierd" },
					typescriptreact = { "prettierd" },
					css = { "prettierd" },
					scss = { "prettierd" },
					html = { "prettierd" },
					markdown = { "prettierd" },
					c = { "clang-format" },
					cpp = { "clang-format" },
					rust = { "rustfmt" },
					lua = { "stylua" },
				},
			})

			vim.keymap.set("n", "<leader>fm", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Format current file" })
		end,
	},
}
