local M = {}

function M.capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

	if ok then
		capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
	end

	return capabilities
end

function M.on_attach(_, bufnr)
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, {
			buffer = bufnr,
			noremap = true,
			silent = true,
			desc = desc,
		})
	end

	map("n", "gd", vim.lsp.buf.definition, "LSP definition")
	map("n", "gD", vim.lsp.buf.declaration, "LSP declaration")
	map("n", "gi", vim.lsp.buf.implementation, "LSP implementation")
	map("n", "gr", vim.lsp.buf.references, "LSP references")

	map("n", "K", function()
		require("config.lsp_hover_docs").hover()
	end, "LSP hover")
	map("n", "<C-k>", vim.lsp.buf.signature_help, "LSP signature")

	map("n", "<leader>rn", vim.lsp.buf.rename, "LSP rename")
	map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP code action")

	if vim.diagnostic.jump then
		map("n", "[d", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, "Previous diagnostic")
		map("n", "]d", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, "Next diagnostic")
	else
		map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
		map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
	end

	map("n", "<leader>e", vim.diagnostic.open_float, "Diagnostic float")
	map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostic list")

	map("n", "<leader>f", function()
		vim.lsp.buf.format({ async = true })
	end, "LSP format")
end

return M
