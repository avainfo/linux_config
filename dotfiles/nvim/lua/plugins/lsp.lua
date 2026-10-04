return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim" },
		opts = {
			ensure_installed = {
				"basedpyright",
				"clangd",
				"lua_ls",
				"ruff",
				"yamlls",
			},
			automatic_enable = false,
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason.nvim" },
		opts = {
			ensure_installed = {
				"clang-format",
				"prettierd",
				"rust-analyzer",
				"stylua",
			},
			auto_update = false,
			run_on_start = true,
		},
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason-lspconfig.nvim",
			"folke/lazydev.nvim",
			"b0o/schemastore.nvim",
		},
		config = function()
			local common = require("config.lsp")
			local capabilities = common.capabilities()

			local servers = {
				clangd = {
					capabilities = vim.tbl_deep_extend("force", {}, capabilities, {
						offsetEncoding = { "utf-16" },
					}),
					on_attach = common.on_attach,
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--completion-style=detailed",
						"--header-insertion=iwyu",
						"--function-arg-placeholders=1",
					},
				},
				basedpyright = {
					capabilities = capabilities,
					on_attach = common.on_attach,
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
				},
				ruff = {
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						client.server_capabilities.hoverProvider = false
						common.on_attach(client, bufnr)
					end,
				},
				lua_ls = {
					capabilities = capabilities,
					on_attach = common.on_attach,
					settings = {
						Lua = {
							runtime = {
								version = "LuaJIT",
							},
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
				tsc = {
					capabilities = capabilities,
					on_attach = common.on_attach,
				},
				yamlls = {
					capabilities = capabilities,
					on_attach = common.on_attach,
					settings = {
						redhat = {
							telemetry = { enabled = false },
						},
						yaml = {
							format = { enable = false },
							validate = true,
							completion = true,
							hover = true,
							schemaStore = {
								enable = false,
								url = "",
							},
							schemas = require("schemastore").yaml.schemas({
								extra = {
									{
										name = "Docker Compose",
										description = "Docker Compose specification",
										url = "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json",
										fileMatch = {
											"compose.yml",
											"compose.yaml",
											"compose.*.yml",
											"compose.*.yaml",
											"docker-compose.yml",
											"docker-compose.yaml",
											"docker-compose.*.yml",
											"docker-compose.*.yaml",
										},
									},
								},
							}),
						},
					},
				},
			}

			if vim.fn.has("nvim-0.11") == 1 then
				for name, config in pairs(servers) do
					vim.lsp.config(name, config)
					vim.lsp.enable(name)
				end
			else
				local lspconfig = require("lspconfig")
				for name, config in pairs(servers) do
					lspconfig[name].setup(config)
				end
			end

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
}
