return {
	{
		"mrcjkb/rustaceanvim",
		version = "^5",
		lazy = false,
		config = function()
			vim.g.rustaceanvim = {
				server = {
					on_attach = function(client, bufnr)
						local opts = { noremap = true, silent = true, buffer = bufnr }
						vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
						vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
						vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
						vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
						vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
						vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
						vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
						vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
						vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
						-- Rust-specific
						vim.keymap.set("n", "<leader>rr", function() vim.cmd("RustLsp runnables") end,
							{ buffer = bufnr, desc = "Rust: runnables" })
						vim.keymap.set("n", "<leader>re", function() vim.cmd("RustLsp expandMacro") end,
							{ buffer = bufnr, desc = "Rust: expand macro" })
						vim.keymap.set("n", "<leader>rc", function() vim.cmd("RustLsp openCargo") end,
							{ buffer = bufnr, desc = "Rust: open Cargo.toml" })
					end,
					settings = {
						["rust-analyzer"] = {
							checkOnSave = { command = "clippy" },
							cargo = { allFeatures = true },
							inlayHints = { enable = true },
						},
					},
				},
			}
		end,
	},
}
