local M = {}

local ns = vim.api.nvim_create_namespace("norminette")
local jobs = {}

local function redraw_statusline()
	vim.cmd("redrawstatus")
end

local function parse_output(data)
	local diagnostics = {}

	for _, raw in ipairs(data or {}) do
		local line = (raw or ""):gsub("\27%[[0-9;]*m", "")

		if
			line ~= ""
			and not line:match("^%s*Setting locale")
			and not line:match("^%s*Diagnostics:?")
			and not line:match("^%s*[%w%._%-/]+:%s*Error!?%s*$")
		then
			local rule, lnum, col, msg =
				line:match("^%s*Error:%s*([%w_%-%./]+)%s*%(%s*line:%s*(%d+),%s*col:%s*(%d+)%s*%):%s*(.+)")

			if lnum and col and msg then
				table.insert(diagnostics, {
					lnum = tonumber(lnum) - 1,
					col = tonumber(col) - 1,
					severity = vim.diagnostic.severity.ERROR,
					message = (rule and (rule .. ": ") or "") .. msg,
					source = "norminette",
				})
			else
				local l2, c2, m2 = line:match(":%s*(%d+):%s*(%d+):%s*Error:%s*(.+)")
				if l2 and c2 and m2 then
					table.insert(diagnostics, {
						lnum = tonumber(l2) - 1,
						col = tonumber(c2) - 1,
						severity = vim.diagnostic.severity.ERROR,
						message = m2,
						source = "norminette",
					})
				end
			end
		end
	end

	return diagnostics
end

function M.check(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	if vim.b[bufnr].norminette_disabled then
		vim.diagnostic.reset(ns, bufnr)
		return
	end

	local file = vim.api.nvim_buf_get_name(bufnr)
	if file == "" then
		return
	end

	if jobs[bufnr] then
		vim.fn.jobstop(jobs[bufnr])
		jobs[bufnr] = nil
	end

	local job_id = vim.fn.jobstart({ "norminette", file }, {
		env = vim.tbl_extend("force", vim.fn.environ(), { NO_COLOR = "1" }),
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(id, data)
			if jobs[bufnr] ~= id then
				return
			end

			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(bufnr) then
					return
				end

				local diagnostics = parse_output(data)
				vim.diagnostic.reset(ns, bufnr)

				if #diagnostics > 0 then
					vim.diagnostic.set(ns, bufnr, diagnostics)
				else
					vim.notify("Norminette OK", vim.log.levels.INFO)
				end
			end)
		end,
		on_stderr = function(id, data)
			if jobs[bufnr] ~= id then
				return
			end

			local lines = {}
			for _, line in ipairs(data or {}) do
				if line and line ~= "" then
					table.insert(lines, line)
				end
			end

			if #lines > 0 then
				vim.schedule(function()
					vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR)
				end)
			end
		end,
		on_exit = function(id)
			if jobs[bufnr] == id then
				jobs[bufnr] = nil
			end
		end,
	})

	if job_id <= 0 then
		vim.notify("Failed to start Norminette", vim.log.levels.ERROR)
		return
	end

	jobs[bufnr] = job_id
end

function M.status()
	local name = vim.api.nvim_buf_get_name(0)

	if not name:match("%.c$") and not name:match("%.h$") then
		return ""
	end

	if vim.b.norminette_disabled then
		return " Norm: %#NormStatusOff#off%*"
	end

	return " Norm: %#NormStatusOn#on%*"
end

local function set_enabled(bufnr, enabled)
	vim.b[bufnr].norminette_disabled = not enabled

	if not enabled then
		vim.diagnostic.reset(ns, bufnr)
	end

	redraw_statusline()
end

function M.setup()
	_G.norminette_status = M.status

	vim.api.nvim_create_user_command("NormOff", function()
		local bufnr = vim.api.nvim_get_current_buf()
		set_enabled(bufnr, false)
		vim.notify("Norminette disabled for this buffer", vim.log.levels.INFO)
	end, { desc = "Disable Norminette diagnostics for the current buffer", force = true })

	vim.api.nvim_create_user_command("NormOn", function()
		local bufnr = vim.api.nvim_get_current_buf()
		set_enabled(bufnr, true)
		vim.notify("Norminette enabled for this buffer", vim.log.levels.INFO)
		M.check(bufnr)
	end, { desc = "Enable Norminette diagnostics for the current buffer", force = true })

	vim.api.nvim_create_user_command("NormToggle", function()
		local bufnr = vim.api.nvim_get_current_buf()
		local enabled = vim.b[bufnr].norminette_disabled == true

		set_enabled(bufnr, enabled)

		if enabled then
			vim.notify("Norminette enabled for this buffer", vim.log.levels.INFO)
			M.check(bufnr)
		else
			vim.notify("Norminette disabled for this buffer", vim.log.levels.INFO)
		end
	end, { desc = "Toggle Norminette diagnostics for the current buffer", force = true })

	vim.keymap.set("n", "<Space>nt", "<cmd>NormToggle<CR>", {
		desc = "Toggle Norminette for current buffer",
	})

	local group = vim.api.nvim_create_augroup("AvaNorminette", { clear = true })

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = group,
		pattern = { "*.c", "*.h" },
		callback = function(args)
			local path = vim.api.nvim_buf_get_name(args.buf)
			set_enabled(args.buf, path:find("/42/", 1, true) ~= nil)
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = { "*.c", "*.h" },
		callback = function(args)
			M.check(args.buf)
		end,
	})
end

return M
