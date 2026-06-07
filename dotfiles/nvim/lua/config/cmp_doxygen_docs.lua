local ok, Entry = pcall(require, "cmp.entry")
if not ok then
	vim.notify("cmp_doxygen_docs: cmp.entry not available", vim.log.levels.WARN)
	return
end

if not Entry.__doxygen_docs_original_get_documentation then
	Entry.__doxygen_docs_original_get_documentation = Entry.get_documentation
end

local original_get_documentation = Entry.__doxygen_docs_original_get_documentation

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function clean_doxygen_line(s)
	s = trim(s)

	s = s:gsub("^/%*%*%s*", "")
	s = s:gsub("^/%*%s*", "")
	s = s:gsub("^%*%/%s*", "")
	s = s:gsub("^%*%s?", "")

	return trim(s)
end

local function compact_blank_lines(lines)
	local out = {}
	local previous_blank = false

	for _, line in ipairs(lines or {}) do
		local is_blank = trim(line) == ""

		if is_blank then
			if not previous_blank and #out > 0 then
				table.insert(out, "")
			end
			previous_blank = true
		else
			table.insert(out, line)
			previous_blank = false
		end
	end

	while #out > 0 and trim(out[1]) == "" do
		table.remove(out, 1)
	end

	while #out > 0 and trim(out[#out]) == "" do
		table.remove(out, #out)
	end

	return out
end

local function doxygen_to_markdown_lines(lines)
	local params = {}
	local returns = {}
	local description = {}
	local other = {}

	for _, raw_line in ipairs(lines or {}) do
		local line = clean_doxygen_line(raw_line)

		local brief_text = line:match("^[@\\]brief%s+(.+)")
		local param_name_with_dir, param_text_with_dir =
			line:match("^[@\\]param%s+%b[]%s*([%w_]+)%s+(.+)")
		local param_name, param_text =
			line:match("^[@\\]param%s+([%w_]+)%s+(.+)")
		local return_text = line:match("^[@\\]return%s+(.+)")
		local retval_text = line:match("^[@\\]retval%s+(.+)")

		if brief_text then
			table.insert(description, brief_text)
		elseif param_name_with_dir and param_text_with_dir then
			table.insert(params, {
				name = param_name_with_dir,
				text = param_text_with_dir,
			})
		elseif param_name and param_text then
			table.insert(params, {
				name = param_name,
				text = param_text,
			})
		elseif return_text then
			table.insert(returns, return_text)
		elseif retval_text then
			table.insert(returns, retval_text)
		elseif line:match("^[@\\]%w+") then
			-- Drop unsupported raw Doxygen commands.
		elseif line ~= "" then
			table.insert(other, line)
		end
	end

	local has_doxygen = #description > 0 or #params > 0 or #returns > 0

	if not has_doxygen then
		return compact_blank_lines(lines)
	end

	local out = {}

	for _, line in ipairs(other) do
		table.insert(out, line)
	end

	if #description > 0 then
		if #out > 0 then
			table.insert(out, "")
		end

		for _, line in ipairs(description) do
			table.insert(out, line)
		end
	end

	if #params > 0 then
		table.insert(out, "")
		table.insert(out, "**Parameters:**")
		table.insert(out, "")

		for _, param in ipairs(params) do
			table.insert(out, string.format("- `%s`: %s", param.name, param.text))
		end
	end

	if #returns > 0 then
		table.insert(out, "")
		table.insert(out, "**Returns:**")
		table.insert(out, "")

		for _, line in ipairs(returns) do
			table.insert(out, line)
		end
	end

	return compact_blank_lines(out)
end

function Entry:get_documentation()
	local docs = original_get_documentation(self)

	if type(docs) ~= "table" then
		return docs
	end

	local joined = table.concat(docs, "\n")

	if joined:match("[@\\]brief")
		or joined:match("[@\\]param")
		or joined:match("[@\\]return")
		or joined:match("[@\\]retval") then
		return doxygen_to_markdown_lines(docs)
	end

	return compact_blank_lines(docs)
end
