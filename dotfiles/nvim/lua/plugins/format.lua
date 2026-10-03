return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")
			local prettier_filetypes = {
				json = true,
				jsonc = true,
				javascript = true,
				javascriptreact = true,
				typescript = true,
				typescriptreact = true,
				css = true,
				scss = true,
				html = true,
				markdown = true,
			}

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
				format_on_save = function(bufnr)
					if prettier_filetypes[vim.bo[bufnr].filetype] then
						return {
							lsp_fallback = true,
							timeout_ms = 1000,
						}
					end
				end,
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
