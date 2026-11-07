-- Conform policy for Python exercises under a directory named exactly "42".
local M = {}
local uv = vim.uv or vim.loop

function M.is_42_path(path)
	return type(path) == "string" and path:find("/42/", 1, true) ~= nil
end

function M.is_42_buffer(bufnr)
	return M.is_42_path(vim.api.nvim_buf_get_name(bufnr or 0))
end

-- Ruff discovers the closest .ruff.toml, ruff.toml, or pyproject.toml
-- containing [tool.ruff]. Never override a project's own Ruff settings.
local function has_project_ruff_config(filename)
	local dir = vim.fs.dirname(filename)
	while dir do
		if uv.fs_stat(dir .. "/.ruff.toml") or uv.fs_stat(dir .. "/ruff.toml") then
			return true
		end

		local pyproject = dir .. "/pyproject.toml"
		if uv.fs_stat(pyproject) then
			local file = io.open(pyproject, "r")
			if file then
				for line in file:lines() do
					if line:match("^%s*%[tool%.ruff%]") or line:match("^%s*%[tool%.ruff%.") then
						file:close()
						return true
					end
				end
				file:close()
			end
		end

		local parent = vim.fs.dirname(dir)
		if not parent or parent == dir then
			break
		end
		dir = parent
	end
	return false
end

function M.ruff_prepend_args(filename)
	if filename ~= "" and not has_project_ruff_config(filename) then
		-- PEP 8's recommended 79 columns, without a per-project config file.
		return { "--config", "line-length = 79" }
	end
	return {}
end

function M.format_current_file()
	local bufnr = vim.api.nvim_get_current_buf()
	if M.is_42_buffer(bufnr) then
		if vim.bo[bufnr].filetype ~= "python" then
			vim.notify("Formatting disabled for non-Python 42 files (C: use Norminette)", vim.log.levels.INFO)
			return
		end
		-- No LSP fallback and no lint autofixes for 42 Python.
		require("conform").format({
			async = false,
			timeout_ms = 1000,
			lsp_format = "never",
		})
		return
	end

	-- Keep the pre-existing outside-42 behavior unchanged.
	require("conform").format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 1000,
	})
end

return M
