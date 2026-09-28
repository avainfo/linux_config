local M = {}

local function unescape_markdown(text)
	return (text:gsub("\\([*_])", "%1"))
end

local function clean_hover_contents(contents)
	if type(contents) == "string" then
		return unescape_markdown(contents)
	end

	if type(contents) ~= "table" then
		return contents
	end

	local cleaned = vim.deepcopy(contents)

	if cleaned.kind == "markdown" and type(cleaned.value) == "string" then
		cleaned.value = unescape_markdown(cleaned.value)
		return cleaned
	end

	if vim.islist(cleaned) then
		for index, item in ipairs(cleaned) do
			if type(item) == "string" then
				cleaned[index] = unescape_markdown(item)
			elseif type(item) == "table" and not item.language and type(item.value) == "string" then
				item.value = unescape_markdown(item.value)
			end
		end
	end

	return cleaned
end

function M.hover()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({
		bufnr = bufnr,
		method = "textDocument/hover",
	})

	local clangd

	for _, client in ipairs(clients) do
		if client.name == "clangd" then
			clangd = client
			break
		end
	end

	if not clangd then
		vim.lsp.buf.hover()
		return
	end

	local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win(), clangd.offset_encoding)

	clangd:request("textDocument/hover", params, function(err, result)
		if err then
			vim.notify(err.message or "LSP hover failed", vim.log.levels.ERROR)
			return
		end

		if not result or not result.contents then
			vim.notify("No information available", vim.log.levels.INFO)
			return
		end

		local contents = vim.lsp.util.convert_input_to_markdown_lines(clean_hover_contents(result.contents))

		if vim.tbl_isempty(contents) then
			vim.notify("No information available", vim.log.levels.INFO)
			return
		end

		vim.lsp.util.open_floating_preview(contents, "markdown", {
			focus_id = "textDocument/hover",
			border = "rounded",
		})
	end, bufnr)
end

return M
