-- === Ava Info — Neovim init.lua ===

require("config.lazy")

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- Active le truecolor (obligatoire pour les thèmes modernes)
    vim.opt.termguicolors = true
    vim.opt.background = "dark"

    -- Applique le thème Catppuccin (doit être installé via Lazy)
    pcall(vim.cmd, "colorscheme catppuccin")
	vim.cmd("hi Normal guibg=#1a1a1a")

    -- Treesitter : coloration activée
    pcall(function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query", "python", "json", "bash", "yaml", "markdown" },
        highlight = { enable = true, additional_vim_regex_highlighting = false },
      })
    end)
  end,
})

-- Encoding
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- Compat
vim.opt.compatible = false

-- Indentation
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.textwidth = 120

-- Numerotation
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
-- This function runs "norminette" on the current buffer and displays errors
-- directly in Neovim's diagnostic system (underlines, virtual text, floating messages)
-- It does not open the quickfix list
local ns = vim.api.nvim_create_namespace("norminette")

local function NorminetteCheck()
	local bufnr = vim.api.nvim_get_current_buf()
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

-- Load the 42 header module
require("ava.header42").setup({
	user = "ando-sou",
	mail = "ando-sou@student.42porto.com",
})

vim.keymap.set("n", "<Space>n", function()
	vim.cmd("write")
end, { desc = "Save and run norminette (via autocmd)" })

vim.keymap.set("n", "<F1>", function()
	require("ava.header42").stdheader()
end, { silent = true, desc = "42 Stdheader" })

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

-- == Telescope settings == --
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
