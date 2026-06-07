-- nvim-cmp configuration for C and Python

return {
	-- Mason : LSP/tools manager
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					border = "rounded",
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗"
					},
				},
			})
		end,
	},

	-- Mason LSP Config
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"basedpyright", -- Python LSP
					"clangd", -- C/C++ LSP
					"ruff", -- Python linter/formatter
				},
				automatic_installation = true,
			})
		end,
	},

	-- Mason Tool Installer
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"clangd",
					"basedpyright",
					"ruff",
					"clang-format", -- For conform.nvim
					"rust-analyzer", -- Rust Analyzer
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},

	-- Main LSP Config
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			-- Check Neovim version
			local nvim_version = vim.version()
			local use_new_api = nvim_version.major > 0 or (nvim_version.major == 0 and nvim_version.minor >= 11)

			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			-- Capabilities
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- LSP Keymaps
			local on_attach = function(client, bufnr)
				local opts = { noremap = true, silent = true, buffer = bufnr }

				-- Navigation
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

				-- Documentation
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

				-- Actions
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				-- Diagnostics
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
				vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

				-- Formatting fallback
				vim.keymap.set("n", "<leader>f", function()
					vim.lsp.buf.format({ async = true })
				end, opts)
			end

			if use_new_api then
				-- Neovim 0.11+ API
				vim.lsp.config('clangd', {
					capabilities = (function()
						local c = vim.tbl_deep_extend("force", {}, capabilities)
						c.offsetEncoding = { "utf-16" }
						return c
					end)(),
					on_attach = on_attach,
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--completion-style=detailed",
						"--header-insertion=iwyu",
						"--function-arg-placeholders=1",
					},
				})

				vim.lsp.config('basedpyright', {
					capabilities = capabilities,
					on_attach = on_attach,
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "basic",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								diagnosticMode = "openFilesOnly",
							},
						},
					},
				})

				vim.lsp.config('ruff', {
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						client.server_capabilities.hoverProvider = false
						on_attach(client, bufnr)
					end,
				})

				-- Enable LSP
				vim.lsp.enable('clangd')
				vim.lsp.enable('basedpyright')
				vim.lsp.enable('ruff')
			else
				-- Neovim < 0.11 API
				local lspconfig = require("lspconfig")

				lspconfig.clangd.setup({
					capabilities = (function()
						local c = vim.tbl_deep_extend("force", {}, capabilities)
						c.offsetEncoding = { "utf-16" }
						return c
					end)(),
					on_attach = on_attach,
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--completion-style=detailed",
						"--header-insertion=iwyu",
						"--function-arg-placeholders",
					},
				})

				lspconfig.basedpyright.setup({
					capabilities = capabilities,
					on_attach = on_attach,
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "basic",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								diagnosticMode = "openFilesOnly",
							},
						},
					},
				})

				lspconfig.ruff.setup({
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						client.server_capabilities.hoverProvider = false
						on_attach(client, bufnr)
					end,
				})
			end

			-- Global diagnostics configuration
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					source = "if_many",
				},
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "✘",
						[vim.diagnostic.severity.WARN] = "▲",
						[vim.diagnostic.severity.HINT] = "⚑",
						[vim.diagnostic.severity.INFO] = "»",
					},
				},
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			})
		end,
	},

	-- Conform
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
					c = { "clang-format" },
					cpp = { "clang-format" },
					rust = { "rustfmt" },
				},
				-- format_on_save = {
				-- lsp_fallback = true,
				-- async = false,
				-- timeout_ms = 1000,
				-- },
			})

			-- Keymap for manual formatting
			vim.keymap.set("n", "<leader>fm", function()
				require("conform").format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Reindent whole file without moving cursor" })
		end,
	},

	-- nvim-cmp
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			require("config.cmp_doxygen_docs")

			-- Load friendly-snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					-- Navigation
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Actions
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),

					-- Tab for navigation + snippets
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				-- Sources (order = priority)
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip",  priority = 750 },
					{ name = "path",     priority = 500 },
				}, {
					{ name = "buffer", priority = 250 },
				}),

				-- Formatting with lspkind icons
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 30,
						ellipsis_char = "...",
						show_labelDetails = false,
					}),
				},

				-- Windows with borders
				window = {
					completion = cmp.config.window.bordered({
						border = "rounded",
						winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
						scrollbar = false,
						col_offset = -3,
						side_padding = 1,
					}),
					documentation = cmp.config.window.bordered({
						border = "rounded",
						winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder,CursorLine:CmpSel,Search:None",
						scrollbar = true,
					}),
				},

				-- Ghost text (optional)
				experimental = {
					ghost_text = true,
				},
			})

			-- Command line completion '/'
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" }
				}
			})

			-- Command line completion ':'
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" }
				}, {
					{ name = "cmdline" }
				})
			})
		end,
	},

	-- Auto-pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local npairs = require("nvim-autopairs")
			npairs.setup({
				check_ts = true,
				ts_config = {
					lua = { "string" },
					javascript = { "template_string" },
				},
			})

			-- Integration with nvim-cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
}
