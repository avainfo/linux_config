-- === Ava Info — Neovim init.lua ===

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

require("config.lazy")

-- =========================
-- Vim Status Line
-- =========================

local function SetStatuslineHighlights()
	vim.api.nvim_set_hl(0, "NormStatusOn", {
		fg = "#a6e3a1",
		bold = true,
	})

	vim.api.nvim_set_hl(0, "NormStatusOff", {
		fg = "#f38ba8",
		bold = true,
	})
end

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function ()
		SetStatuslineHighlights()
		-- CMP floating windows
        vim.api.nvim_set_hl(0, "CmpNormal",    { bg = "#242438" })
        vim.api.nvim_set_hl(0, "CmpBorder",    { fg = "#7c6f9f" })
        vim.api.nvim_set_hl(0, "CmpDocNormal", { bg = "#1e1e2e" })
        vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#585b70" })
        vim.api.nvim_set_hl(0, "CmpSel",       { bg = "#313244", bold = true })
	end,
})

vim.opt.statusline = table.concat({
	" %f",
	"%m",
	"%=",
	"%{%v:lua.norminette_status()%}",
	" %l,%c",
	" %p%% ",
})

vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        vim.opt.termguicolors = true
        vim.opt.background = "dark"

        pcall(vim.cmd, "colorscheme catppuccin")
        vim.cmd("hi Normal guibg=#1a1a1a")

        SetStatuslineHighlights()

        -- CMP floating windows (init au premier démarrage)
        vim.api.nvim_set_hl(0, "CmpNormal",    { bg = "#242438" })
        vim.api.nvim_set_hl(0, "CmpBorder",    { fg = "#7c6f9f" })
        vim.api.nvim_set_hl(0, "CmpDocNormal", { bg = "#1e1e2e" })
        vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#585b70" })
        vim.api.nvim_set_hl(0, "CmpSel",       { bg = "#313244", bold = true })
    end,
})

-- Time Neovim waits for mapped key sequences
vim.opt.timeout = true
vim.opt.timeoutlen = 10000

-- Encoding
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- Global indentation
-- Default: tabs, useful for C / 42
vim.opt.expandtab = false
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.textwidth = 120

-- Python : PEP8 = 4 spaces, no tabs
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.cindent = false
		vim.opt_local.smartindent = true
	end,
})

-- C / C++: tabs, useful for 42 and your low-level style
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "h", "hpp" },
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.cindent = true
	end,
})

-- Numbering
vim.opt.number = true
vim.opt.relativenumber = true

-- Shortcut F2 : save in normal/insert
vim.keymap.set("n", "<F2>", ":w<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<F2>", "<Esc>:w<CR>i", { noremap = true, silent = true })

vim.keymap.set("n", "<C-Left>", "b", { noremap = true })
vim.keymap.set("n", "<C-Right>", "w", { noremap = true })
vim.keymap.set("i", "<C-Left>", "<C-o>b", { noremap = true })
vim.keymap.set("i", "<C-Right>", "<C-o>w", { noremap = true })

-- =========================
-- Norminette (Native Diagnostics)
-- =========================
local ns = vim.api.nvim_create_namespace("norminette")

local function RefreshStatusline()
	vim.cmd("redrawstatus")
end

local function NorminetteCheck()
	local bufnr = vim.api.nvim_get_current_buf()

	if vim.b[bufnr].norminette_disabled then
		vim.diagnostic.reset(ns, bufnr)
		return
	end

	local file = vim.api.nvim_buf_get_name(bufnr)
	if file == "" then
		vim.notify("No file to check.", vim.log.levels.WARN)
		return
	end

	local cmd = { "bash", "-lc", "NO_COLOR=1 norminette " .. vim.fn.shellescape(file) }

	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			vim.diagnostic.reset(ns, bufnr)
			if not data or #data == 0 then return end

			local diags = {}
			for _, raw in ipairs(data) do
				local line = (raw or ""):gsub("\27%[[0-9;]*m", "")
				if line ~= "" then
					if line:match("^%s*Setting locale")
						or line:match("^%s*Diagnostics:?")
						or line:match("^%s*[%w%._%-/]+:%s*Error!?%s*$") then
						-- skip
					else
						local rule, lnum, col, msg =
							line:match("^%s*Error:%s*([%w_%-%./]+)%s*%(%s*line:%s*(%d+),%s*col:%s*(%d+)%s*%):%s*(.+)")
						if lnum and col and msg then
							table.insert(diags, {
								lnum     = tonumber(lnum) - 1,
								col      = tonumber(col) - 1,
								severity = vim.diagnostic.severity.ERROR,
								message  = (rule and (rule .. ": ") or "") .. msg,
								source   = "norminette",
							})
						else
							local l2, c2, m2 = line:match(":%s*(%d+):%s*(%d+):%s*Error:%s*(.+)")
							if l2 and c2 and m2 then
								table.insert(diags, {
									lnum     = tonumber(l2) - 1,
									col      = tonumber(c2) - 1,
									severity = vim.diagnostic.severity.ERROR,
									message  = m2,
									source   = "norminette",
								})
							end
						end
					end
				end
			end

			if #diags > 0 then
				vim.diagnostic.set(ns, bufnr, diags)
			else
				vim.notify("Norminette OK", vim.log.levels.INFO)
			end
		end,
		on_stderr = function(_, err)
			if err and #err > 0 then
				vim.notify(table.concat(err, "\n"), vim.log.levels.ERROR)
			end
		end,
	})
end

vim.api.nvim_create_user_command("NormOff", function()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.b[bufnr].norminette_disabled = true
	vim.diagnostic.reset(ns, bufnr)
	RefreshStatusline()
	vim.notify("Norminette disabled for this buffer", vim.log.levels.INFO)
end, { desc = "Disable Norminette diagnostics for the current buffer" })

vim.api.nvim_create_user_command("NormOn", function()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.b[bufnr].norminette_disabled = false
	RefreshStatusline()
	vim.notify("Norminette enabled for this buffer", vim.log.levels.INFO)
	NorminetteCheck()
end, { desc = "Enable Norminette diagnostics for the current buffer" })

vim.api.nvim_create_user_command("NormToggle", function()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.b[bufnr].norminette_disabled = not vim.b[bufnr].norminette_disabled

	if vim.b[bufnr].norminette_disabled then
		vim.diagnostic.reset(ns, bufnr)
		RefreshStatusline()
		vim.notify("Norminette disabled for this buffer", vim.log.levels.INFO)
	else
		RefreshStatusline()
		vim.notify("Norminette enabled for this buffer", vim.log.levels.INFO)
		NorminetteCheck()
	end
end, { desc = "Toggle Norminette diagnostics for the current buffer" })

vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = { "*.c", "*.h" },
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local path = vim.api.nvim_buf_get_name(bufnr)

        if path:match("/42/") then
            vim.b[bufnr].norminette_disabled = false
        else
            vim.b[bufnr].norminette_disabled = true
        end
    end,
})

vim.keymap.set("n", "<Space>nt", "<cmd>NormToggle<CR>", {
	desc = "Toggle Norminette for current buffer",
})

local function norminette_status()
	local name = vim.api.nvim_buf_get_name(0)

	if not name:match("%.c$") and not name:match("%.h$") then
		return ""
	end

	if vim.b.norminette_disabled then
		return " Norm: %#NormStatusOff#off%*"
	end

	return " Norm: %#NormStatusOn#on%*"
end

_G.norminette_status = norminette_status

-- Load the header module
require("ava.header").setup({
	user = "ando-sou",
	mail = "ando-sou@student.42porto.com",
})

vim.keymap.set("n", "<Space>n", function()
	vim.cmd("write")
end, { desc = "Save and run norminette (via autocmd)" })

-- License/header shortcuts.
-- Press F1 followed by a letter to insert the matching file header:
--   F1 + f: 42 stdheader
--   F1 + m: MIT license header
--   F1 + a: Apache 2.0 license header
--   F1 + p: proprietary/private header
local headers = require("ava.header")

vim.keymap.set("n", "<F1>f", function()
	headers.stdheader()
end, { silent = true, desc = "Header: 42 stdheader" })

vim.keymap.set("n", "<F1>m", function()
	headers.mit_header()
end, { silent = true, desc = "Header: MIT" })

vim.keymap.set("n", "<F1>a", function()
	headers.apache_header()
end, { silent = true, desc = "Header: Apache 2.0" })

vim.keymap.set("n", "<F1>p", function()
	headers.private_header()
end, { silent = true, desc = "Header: proprietary/private" })

-- Map Space+s to open diagnostics float
vim.keymap.set("n", "<Space>s", function()
	vim.diagnostic.open_float(nil, { focus = true })
end, { desc = "Show diagnostics at cursor" })

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.c", "*.h" },
	callback = function(args) NorminetteCheck() end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    if vim.bo.modifiable then
      vim.opt_local.comments = "sl:/*,mb:\\ *,elx:\\ *"
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "gitcommit",
    callback = function()
        vim.opt_local.textwidth = 72
        vim.opt_local.colorcolumn = "51,73"
        vim.opt_local.spell = true
        vim.opt_local.wrap = true
    end,
})

-- Telescope keymaps are in lua/plugins/telescope.lua

-- =========================
-- Competitive Programming
-- =========================
local cp = require("ava.cp")

-- <F5> : compile + interactive run
vim.keymap.set("n", "<F5>", cp.run, { desc = "CP: compile & run" })

-- <F6> : compile + run with input.txt
vim.keymap.set("n", "<F6>", cp.run_with_input, { desc = "CP: run with input.txt" })

-- <F7> : only compile (errors check)
vim.keymap.set("n", "<F7>", cp.build, { desc = "CP: build only" })

-- <F8> : open/create input.txt in vsplit
vim.keymap.set("n", "<F8>", cp.open_input, { desc = "CP: open input.txt" })

-- <Space>ct : load cp template in an empty buffer .cpp
vim.keymap.set("n", "<Space>ct", cp.load_template, { desc = "CP: load template" })

-- Quit terminal with Escape
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, desc = "Terminal: normal mode" })

-- Yank to system clipboard with y+
-- vim.keymap.set({ "n", "x" }, "y+", '"+y', {
-- 	noremap = true,
-- 	silent = true,
-- 	desc = "Yank to system clipboard",
-- })

-- vim.keymap.set({ "n", "i", "v" }, "<Left>", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set({ "n", "i", "v" }, "<Right>", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("i", "<C-x>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype

    if ft == "cmp_docs" then
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

      vim.notify(
        "CMP DOCS CONTENT:\n\n" .. table.concat(lines, "\n"),
        vim.log.levels.INFO,
        { title = "cmp_docs debug" }
      )
    end
  end
end, { desc = "Debug cmp docs content" })

-- =========================
-- Python formatting
-- =========================
vim.keymap.set("n", "<leader>cp", function()
	vim.cmd("write")
	vim.cmd("botright split")
	vim.cmd("resize 12")
	vim.cmd("terminal checkp **/*.py")
end, { desc = "Run checkp on Python files" })
