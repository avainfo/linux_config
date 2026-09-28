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

local function parse_command(line)
	local command, rest = line:match("^@([%w_]+)%s*(.*)")
	if command then
		return command:lower(), rest
	end

	command, rest = line:match("^\\([%w_]+)%s*(.*)")
	if command then
		return command:lower(), rest
	end

	return nil, nil
end

local function push_blank(out)
	if #out > 0 and out[#out] ~= "" then
		table.insert(out, "")
	end
end

local function start_section(out, state, name, title)
	if state.section == name then
		return
	end

	push_blank(out)
	table.insert(out, title)
	table.insert(out, "")
	state.section = name
end

local labels = {
	note = "Note",
	warning = "Warning",
	attention = "Attention",
	deprecated = "Deprecated",
	todo = "Todo",
	see = "See",
	since = "Since",
	remark = "Remark",
	remarks = "Remarks",
}

local function doxygen_to_markdown_lines(lines)
	local out = {}
	local state = { section = nil }
	local has_doxygen = false

	for _, raw_line in ipairs(lines or {}) do
		local line = clean_doxygen_line(raw_line)
		local command, rest = parse_command(line)

		if command then
			has_doxygen = true

			if command == "brief" then
				state.section = nil
				if rest ~= "" then
					table.insert(out, rest)
				end
			elseif command == "param" or command == "tparam" then
				start_section(out, state, command == "param" and "params" or "tparams", command == "param" and "**Parameters:**" or "**Template parameters:**")

				local direction, name, text = rest:match("^%[([^%]]+)%]%s*([%w_]+)%s*(.*)")
				if not name then
					name, text = rest:match("^([%w_]+)%s*(.*)")
				end

				if name then
					local prefix = direction and (" *[" .. direction .. "]*") or ""
					table.insert(out, string.format("- %s%s: %s", "`" .. name .. "`", prefix, text or ""))
				elseif rest ~= "" then
					table.insert(out, "- " .. rest)
				end
			elseif command == "return" or command == "returns" then
				start_section(out, state, "returns", "**Returns:**")
				if rest ~= "" then
					table.insert(out, rest)
				end
			elseif command == "retval" then
				start_section(out, state, "returns", "**Returns:**")
				local value, text = rest:match("^([^%s]+)%s*(.*)")
				if value then
					table.insert(out, string.format("- %s: %s", "`" .. value .. "`", text or ""))
				elseif rest ~= "" then
					table.insert(out, rest)
				end
			elseif labels[command] then
				state.section = nil
				push_blank(out)
				local label = labels[command]
				if command == "note" or command == "warning" or command == "attention" or command == "deprecated" or command == "todo" then
					table.insert(out, string.format("> **%s:** %s", label, rest))
				else
					table.insert(out, string.format("**%s:** %s", label, rest))
				end
			else
				state.section = nil
				push_blank(out)
				if rest ~= "" then
					table.insert(out, string.format("**@%s:** %s", command, rest))
				else
					table.insert(out, "@" .. command)
				end
			end
		else
			state.section = nil
			table.insert(out, line)
		end
	end

	if not has_doxygen then
		return compact_blank_lines(lines)
	end

	return compact_blank_lines(out)
end

function Entry:get_documentation()
	local docs = original_get_documentation(self)

	if type(docs) ~= "table" then
		return docs
	end

	return doxygen_to_markdown_lines(docs)
end
