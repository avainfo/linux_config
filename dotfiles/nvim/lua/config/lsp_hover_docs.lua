local M = {}

local function unescape_plain_markdown(text)
	return (text:gsub("\\([*_])", "%1"))
end

local function clean_inline_markdown(line)
	local out = {}
	local start = 1
	local in_code = false
	local i = 1

	while i <= #line do
		if line:sub(i, i) == "`" then
			local j = i
			while line:sub(j + 1, j + 1) == "`" do
				j = j + 1
			end

			local segment = line:sub(start, i - 1)
			table.insert(out, in_code and segment or unescape_plain_markdown(segment))
			table.insert(out, line:sub(i, j))
			in_code = not in_code
			i = j + 1
			start = i
		else
			i = i + 1
		end
	end

	local tail = line:sub(start)
	table.insert(out, in_code and tail or unescape_plain_markdown(tail))
	return table.concat(out)
end

local function clean_markdown(text)
	local lines = vim.split(text, "\n", { plain = true })
	local out = {}
	local in_fence = false

	for _, line in ipairs(lines) do
		if line:match("^%s*```") or line:match("^%s*~~~") then
			in_fence = not in_fence
			table.insert(out, line)
		elseif in_fence then
			table.insert(out, line)
		else
			table.insert(out, clean_inline_markdown(line))
		end
	end

	return table.concat(out, "\n")
end

local function clean_hover_contents(contents)
	if type(contents) == "string" then
		return clean_markdown(contents)
	end

	if type(contents) ~= "table" then
		return contents
	end

	local cleaned = vim.deepcopy(contents)

	if cleaned.kind == "markdown" and type(cleaned.value) == "string" then
		cleaned.value = clean_markdown(cleaned.value)
		return cleaned
	end

	if vim.islist(cleaned) then
		for index, item in ipairs(cleaned) do
			if type(item) == "string" then
				cleaned[index] = clean_markdown(item)
			elseif type(item) == "table" and not item.language and type(item.value) == "string" then
				item.value = clean_markdown(item.value)
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
		vim.lsp.buf.hover({ border = "rounded" })
		return
	end

	local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win(), clangd.offset_encoding)

	clangd:request("textDocument/hover", params, function(err, result)
		if err then
			vim.schedule(function()
				vim.notify(err.message or "LSP hover failed", vim.log.levels.ERROR)
			end)
			return
		end

		if not result or not result.contents then
			return
		end

		local contents = vim.lsp.util.convert_input_to_markdown_lines(clean_hover_contents(result.contents))
		if vim.tbl_isempty(contents) then
			return
		end

		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			vim.lsp.util.open_floating_preview(contents, "markdown", {
				focus_id = "textDocument/hover",
				border = "rounded",
			})
		end)
	end, bufnr)
end

return M
