-- ava/header.lua

local M = {}

M.identity = {
	school42 = {
		user = "ando-sou",
		mail = "ando-sou@student.42porto.com",
	},
	ava = {
		company = "Ava Info Conseils",
		author = "Antonin Do Souto",
		contact = "antonindosouto@gmail.com",
	},
}

-- ASCII art and layout
M.asciiart = {
	"        :::      ::::::::",
	"      :+:      :+:    :+:",
	"    +:+ +:+         +:+  ",
	"  +#+  +:+       +#+     ",
	"+#+#+#+#+#+   +#+        ",
	"     #+#    #+#          ",
	"    ###   ########.fr    ",
}
M.length = 80
M.margin = 5
M.start = "/*"
M._end = "*/"
M.fill = "*"

-- Filetype → comment tokens
M.types = {
	{
		[[\.c$\|\.h$\|\.cc$\|\.hh$\|\.cpp$\|\.hpp$\|\.tpp$\|\.ipp$\|\.cxx$\|\.go$\|\.rs$\|\.php$\|\.java$\|\.kt$\|\.kts$]],
		"/*",
		"*/",
		"*",
	},
	{
		[[\.htm$\|\.html$\|\.xml$]],
		"<!--",
		"-->",
		"*",
	},
	{
		[[\.js$\|\.ts$]],
		"//",
		"//",
		"*",
	},
	{
		[[\.tex$]],
		"%",
		"%",
		"*",
	},
	{
		[[\.ml$\|\.mli$\|\.mll$\|\.mly$]],
		"(*",
		"*)",
		"*",
	},
	{
		[[\.vim$\|\vimrc$]],
		'"',
		'"',
		"*",
	},
	{
		[[\.el$\|\emacs$\|\.asm$]],
		";",
		";",
		"*",
	},
	{
		[[\.f90$\|\.f95$\|\.f03$\|\.f$\|\.for$]],
		"!",
		"!",
		"/",
	},
	{
		[[\.lua$]],
		"--",
		"--",
		"-",
	},
	{
		[[\.py$]],
		"#",
		"#",
		"*",
	},
}

-- Helpers
local function strlen(s)
	return (type(s) == "string") and #s or 0
end
local function str(s)
	return (type(s) == "string") and s or ""
end
local function spaces(n)
	return string.rep(" ", math.max(0, n or 0))
end

local function filename()
	local f = vim.fn.expand("%:t")
	return (f == nil or f == "") and "< new >" or f
end

local function user()
	return vim.g.user42 or M.identity.school42.user or os.getenv("USER") or "marvin"
end

local function mail()
	return vim.g.mail42 or M.identity.school42.mail or os.getenv("MAIL") or "marvin@42.fr"
end

local function date_str()
	return os.date("%Y/%m/%d %H:%M:%S")
end

local function ascii(n)
	return M.asciiart[n - 2] or ""
end

-- Pick comment tokens based on file name
local function pick_filetype_tokens()
	local f = filename()
	M.start, M._end, M.fill = "#", "#", "*"
	for _, t in ipairs(M.types) do
		local re, s, e, fill = t[1], t[2], t[3], t[4]
		if vim.regex(re):match_str(f) ~= nil then
			M.start, M._end, M.fill = s, e, fill
			break
		end
	end
end

local function textline(left, right)
	left, right = str(left), str(right)
	local sstart, send = str(M.start), str(M._end)

	local inner = M.length - M.margin * 2
	local rightlen = strlen(right)
	local maxleft = inner - rightlen
	if maxleft < 0 then
		maxleft = 0
	end
	if strlen(left) > maxleft then
		left = left:sub(1, maxleft)
	end
	local pad = inner - strlen(left) - rightlen

	return sstart
		.. string.rep(" ", math.max(0, M.margin - strlen(sstart)))
		.. left
		.. string.rep(" ", math.max(0, pad))
		.. right
		.. string.rep(" ", math.max(0, M.margin - strlen(send)))
		.. send
end

local function line(n)
	local sstart, send = str(M.start), str(M._end)
	local fill = str(M.fill)

	if n == 1 or n == 11 then
		return sstart
			.. " "
			.. string.rep(fill, math.max(0, M.length - strlen(sstart) - strlen(send) - 2))
			.. " "
			.. send
	elseif n == 2 or n == 10 then
		return textline("", "")
	elseif n == 3 or n == 5 or n == 7 then
		return textline("", ascii(n))
	elseif n == 4 then
		return textline(filename(), ascii(n))
	elseif n == 6 then
		return textline("By: " .. user() .. " <" .. mail() .. ">", ascii(n))
	elseif n == 8 then
		return textline("Created: " .. date_str() .. " by " .. user(), ascii(n))
	elseif n == 9 then
		return textline("Updated: " .. date_str() .. " by " .. user(), ascii(n))
	end
	return ""
end

local function header_lines()
	local out = {}
	for i = 1, 11 do
		table.insert(out, line(i))
	end
	return out
end

local function not_rebasing(bufnr)
	if not vim.system then
		return true
	end

	local file = vim.api.nvim_buf_get_name(bufnr)
	local cwd = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.uv.cwd()
	local result = vim.system({ "git", "rev-parse", "--git-dir" }, {
		cwd = cwd,
		text = true,
	}):wait()

	if result.code ~= 0 then
		return true
	end

	local gitdir = (result.stdout or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if gitdir == "" then
		return true
	end

	if not gitdir:match("^/") then
		gitdir = vim.fs.joinpath(cwd, gitdir)
	end

	gitdir = vim.fs.normalize(gitdir)

	return not vim.uv.fs_stat(vim.fs.joinpath(gitdir, "rebase-merge"))
		and not vim.uv.fs_stat(vim.fs.joinpath(gitdir, "rebase-apply"))
end

function M.insert()
	pick_filetype_tokens()
	local bufnr = 0
	local lines = header_lines()
	table.insert(lines, "") -- blank line after header
	vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)
end

function M.update()
	pick_filetype_tokens()
	local bufnr = 0
	local l9 = vim.api.nvim_buf_get_lines(bufnr, 8, 9, false)[1] or ""
	local check = M.start .. spaces(M.margin - strlen(M.start)) .. "Updated: "
	if l9:sub(1, #check) == check then
		local safe_to_update = not_rebasing(bufnr)
		if vim.bo[bufnr].modified and safe_to_update then
			vim.api.nvim_buf_set_lines(bufnr, 8, 9, false, { line(9) })
		end
		if safe_to_update then
			vim.api.nvim_buf_set_lines(bufnr, 3, 4, false, { line(4) })
		end
		return 0
	end
	return 1
end

function M.stdheader()
	if M.update() == 1 then
		M.insert()
	end
end

function M.fix_merge_conflict()
	pick_filetype_tokens()
	local bufnr = 0
	local function get(i)
		return (vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1] or "")
	end
	local check = M.start .. spaces(M.margin - strlen(M.start)) .. "Updated: "

	if
		get(9):match("^<<<<<<<")
		and get(11):match("^=======")
		and get(13):match("^>>>>>>>")
		and get(10):sub(1, #check) == check
	then
		local repl = { line(9), line(10), line(11) }
		vim.api.nvim_buf_set_lines(bufnr, 8, 11, false, repl)
		vim.api.nvim_buf_set_lines(bufnr, 11, 15, false, {})
		vim.notify("42header conflicts automatically resolved!", vim.log.levels.INFO)
	elseif
		get(8):match("^<<<<<<<")
		and get(11):match("^=======")
		and get(14):match("^>>>>>>>")
		and get(10):sub(1, #check) == check
	then
		local repl = { line(8), line(9), line(10), line(11) }
		vim.api.nvim_buf_set_lines(bufnr, 7, 11, false, repl)
		vim.api.nvim_buf_set_lines(bufnr, 11, 16, false, {})
		vim.notify("42header conflicts automatically resolved!", vim.log.levels.INFO)
	end
end

local function insert_plain_header(lines, replace_empty, prelude)
	pick_filetype_tokens()

	local bufnr = 0
	local start_token = str(M.start)
	local end_token = str(M._end)

	local out = {}

	local is_block_comment = start_token ~= end_token

	if start_token == "/*" and end_token == "*/" then
		table.insert(out, "/*")
		for _, l in ipairs(lines) do
			if l == "" then
				table.insert(out, " *")
			else
				table.insert(out, " * " .. l)
			end
		end
		table.insert(out, " */")
	elseif is_block_comment then
		table.insert(out, start_token)
		for _, l in ipairs(lines) do
			if l == "" then
				table.insert(out, "")
			else
				table.insert(out, " " .. l)
			end
		end
		table.insert(out, end_token)
	else
		for _, l in ipairs(lines) do
			if l == "" then
				table.insert(out, start_token)
			else
				table.insert(out, start_token .. " " .. l)
			end
		end
	end

	table.insert(out, "")
	if prelude then
		for i = #prelude, 1, -1 do
			table.insert(out, 1, prelude[i])
		end
	end
	vim.api.nvim_buf_set_lines(bufnr, 0, replace_empty and -1 or 0, false, out)
end

function M.mit_header(replace_empty)
	local ava = M.identity.ava
	local prelude
	if replace_empty then
		local name = filename():lower()
		if name:match("%.php$") then
			prelude = { "<?php", "" }
		elseif name:match("%.xml$") then
			prelude = { '<?xml version="1.0" encoding="UTF-8"?>', "" }
		elseif name:match("%.html?$") then
			prelude = { "<!DOCTYPE html>", "" }
		end
	end
	insert_plain_header({
		ava.company,
		"",
		"Author: " .. ava.author,
		"Contact: " .. ava.contact,
		"",
		"Copyright (c) " .. os.date("%Y") .. " " .. ava.author,
		"",
		"SPDX-License-Identifier: MIT",
	}, replace_empty, prelude)
end

function M.apache_header()
	local ava = M.identity.ava
	insert_plain_header({
		ava.company,
		"",
		"Author: " .. ava.author,
		"Contact: " .. ava.contact,
		"",
		"Copyright (c) " .. os.date("%Y") .. " " .. ava.author,
		"",
		"SPDX-License-Identifier: Apache-2.0",
	})
end

function M.private_header()
	local ava = M.identity.ava
	insert_plain_header({
		ava.company,
		"",
		"Author: " .. ava.author,
		"Contact: " .. ava.contact,
		"",
		"Proprietary / Commercial License",
		"",
		"Copyright (c) " .. os.date("%Y") .. " " .. ava.author,
		"",
		"All rights reserved.",
		"",
		"This repository contains proprietary software and documentation.",
		"Unless explicitly stated otherwise in a subdirectory LICENSE file,",
		"all files in this repository are proprietary and may not be copied,",
		"modified, distributed, or used without prior written permission.",
	})
end

-- New, empty files only. Oil creates its files before opening them, so
-- BufNewFile alone cannot reliably distinguish Oil creations from old empty files.
local oil_created = {}

local function file_key(name)
	if name == "" then
		return nil
	end
	if name:sub(1, 6) == "oil://" then
		name = name:sub(7)
	elseif name:find("://", 1, true) then
		return name
	end
	return vim.fs.normalize(vim.fn.fnamemodify(name, ":p"))
end

local function has_header_filetype(name)
	local basename = name:match("([^/]+)$") or name
	for _, spec in ipairs(M.types) do
		if vim.regex(spec[1]):match_str(basename) then
			return true
		end
	end
	return false
end

local function insert_for_new_file(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		return
	end

	local name = vim.api.nvim_buf_get_name(bufnr)
	if not has_header_filetype(name) then
		return
	end

	local opts = vim.bo[bufnr]
	if not opts.modifiable or opts.modified or (opts.buftype ~= "" and opts.buftype ~= "acwrite") then
		return
	end

	if vim.api.nvim_buf_line_count(bufnr) ~= 1
		or vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] ~= ""
	then
		return
	end

	vim.api.nvim_buf_call(bufnr, function()
		M.mit_header(true)
	end)

	-- Leave the cursor where the next line of code should be written.
	if vim.api.nvim_get_current_buf() == bufnr then
		vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(bufnr), 0 })
	end
end

local function track_oil_creations(args)
	if not args.data or args.data.err then
		return
	end
	for _, action in ipairs(args.data.actions or {}) do
		if action.type == "create" and action.entry_type == "file" then
			local key = file_key(action.url)
			if key then
				oil_created[key] = true
			end
		end
	end
end

local function finish_oil_creation(args)
	local key = file_key(vim.api.nvim_buf_get_name(args.buf))
	if key and oil_created[key] then
		oil_created[key] = nil
		insert_for_new_file(args.buf)
	end
end

function M.setup(opts)
	opts = opts or {}

	if opts.user then
		M.identity.school42.user = opts.user
	end
	if opts.mail then
		M.identity.school42.mail = opts.mail
	end
	if opts.school42 then
		M.identity.school42 = vim.tbl_deep_extend("force", M.identity.school42, opts.school42)
	end
	if opts.ava then
		M.identity.ava = vim.tbl_deep_extend("force", M.identity.ava, opts.ava)
	end

	vim.api.nvim_create_user_command("Stdheader", function()
		M.stdheader()
	end, { force = true })
	local aug = vim.api.nvim_create_augroup("stdheader", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = aug,
		pattern = "*",
		callback = function()
			M.update()
		end,
	})
	vim.api.nvim_create_autocmd("BufReadPost", {
		group = aug,
		pattern = "*",
		callback = function()
			M.fix_merge_conflict()
		end,
	})
	vim.api.nvim_create_autocmd("BufNewFile", {
		group = aug,
		callback = function(args)
			-- Oil SSH file reads are asynchronous; wait for OilActionsPost + BufReadPost.
			if not args.file:find("://", 1, true) then
				insert_for_new_file(args.buf)
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufFilePost", {
		group = aug,
		callback = function(args)
			-- Covers :enew followed by :file new.cpp (not existing files).
			local name = vim.api.nvim_buf_get_name(args.buf)
			if name ~= "" and not name:find("://", 1, true) and not vim.uv.fs_stat(name) then
				insert_for_new_file(args.buf)
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		group = aug,
		pattern = "OilActionsPost",
		callback = track_oil_creations,
	})

	vim.api.nvim_create_autocmd("BufReadPost", {
		group = aug,
		callback = finish_oil_creation,
	})
end

return M
