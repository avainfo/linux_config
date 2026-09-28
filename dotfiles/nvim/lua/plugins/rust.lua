return {
	{
		"mrcjkb/rustaceanvim",
		version = "^5",
		lazy = false,
		config = function()
			local common = require("config.lsp")

			vim.g.rustaceanvim = {
				server = {
					on_attach = function(client, bufnr)
						common.on_attach(client, bufnr)

						vim.keymap.set("n", "<leader>rr", function()
							vim.cmd("RustLsp runnables")
						end, { buffer = bufnr, desc = "Rust: runnables" })

						vim.keymap.set("n", "<leader>re", function()
							vim.cmd("RustLsp expandMacro")
						end, { buffer = bufnr, desc = "Rust: expand macro" })

						vim.keymap.set("n", "<leader>rc", function()
							vim.cmd("RustLsp openCargo")
						end, { buffer = bufnr, desc = "Rust: open Cargo.toml" })
					end,
					settings = {
						["rust-analyzer"] = {
							check = { command = "clippy" },
							cargo = { allFeatures = true },
							inlayHints = { enable = true },
						},
					},
				},
			}
		end,
	},
}
