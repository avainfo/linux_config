return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")
			local formatting_42 = require("ava.format_42")
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
				yaml = true,
				["yaml.docker-compose"] = true,
			}

			local function non_42_formatter(bufnr, name)
				if formatting_42.is_42_buffer(bufnr) then
					return {}
				end
				return { name }
			end

			conform.setup({
				formatters_by_ft = {
					python = function(bufnr)
						if formatting_42.is_42_buffer(bufnr) then
							return { "ruff_42_format", lsp_format = "never" }
						end
						return { "ruff_fix", "ruff_organize_imports", "ruff_format" }
					end,
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
					yaml = { "prettierd" },
					["yaml.docker-compose"] = { "prettierd" },
					c = function(bufnr)
						return non_42_formatter(bufnr, "clang-format")
					end,
					cpp = function(bufnr)
						return non_42_formatter(bufnr, "clang-format")
					end,
					rust = { "rustfmt" },
					lua = { "stylua" },
				},
				formatters = {
					ruff_42_format = {
						inherit = "ruff_format",
						prepend_args = function(_, ctx)
							return formatting_42.ruff_prepend_args(ctx.filename)
						end,
					},
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

			vim.keymap.set("n", "<leader>fm", formatting_42.format_current_file, {
				desc = "Format current file (42 Python: Ruff format only)",
			})
		end,
	},
}
