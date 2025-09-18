-- ava/header42.lua

local M = {}

-- Defaults (you can override in setup)
M.user42 = "ando-sou"
M.mail42 = "ando-sou@student.42porto.com"

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
M.start  = "/*"
M._end   = "*/"
M.fill   = "*"

-- Filetype → comment tokens
M.types = {
  { [[\.c$\|\.h$\|\.cc$\|\.hh$\|\.cpp$\|\.hpp$\|\.tpp$\|\.ipp$\|\.cxx$\|\.go$\|\.rs$\|\.php$\|\.java$\|\.kt$\|\.kts$]], "/*",  "*/",  "*" },
  { [[\.htm$\|\.html$\|\.xml$]],                                                                        "<!--", "-->", "*" },
  { [[\.js$\|\.ts$]],                                                                                   "//",   "//",  "*" },
  { [[\.tex$]],                                                                                         "%",    "%",   "*" },
  { [[\.ml$\|\.mli$\|\.mll$\|\.mly$]],                                                                  "(*",   "*)",  "*" },
  { [[\.vim$\|\vimrc$]],                                                                                "\"",   "\"",  "*" },
  { [[\.el$\|\emacs$\|\.asm$]],                                                                         ";",    ";",   "*" },
  { [[\.f90$\|\.f95$\|\.f03$\|\.f$\|\.for$]],                                                           "!",    "!",   "/" },
  { [[\.lua$]],                                                                                         "--",   "--",  "-" },
  { [[\.py$]],                                                                                          "#",    "#",   "*" },
}

-- Helpers
local function strlen(s) return (type(s) == "string") and #s or 0 end
local function str(s)    return (type(s) == "string") and s or "" end
local function spaces(n) return string.rep(" ", math.max(0, n or 0)) end

local function filename()
  local f = vim.fn.expand("%:t")
  return (f == nil or f == "") and "< new >" or f
end

local function user()
  return vim.g.user42 or M.user42 or os.getenv("USER") or "marvin"
end

local function mail()
  return vim.g.mail42 or M.mail42 or os.getenv("MAIL") or "marvin@42.fr"
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
  if maxleft < 0 then maxleft = 0 end
  if strlen(left) > maxleft then left = left:sub(1, maxleft) end
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
    return sstart .. " "
      .. string.rep(fill, math.max(0, M.length - strlen(sstart) - strlen(send) - 2))
      .. " " .. send
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
  for i = 1, 11 do table.insert(out, line(i)) end
  return out
end

local function not_rebasing()
  local out = vim.fn.system("ls `git rev-parse --git-dir 2>/dev/null` | grep rebase | wc -l")
  local n = tonumber((out or ""):match("%d+")) or 0
  return n == 0
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
    if vim.bo.modified and not_rebasing() then
      vim.api.nvim_buf_set_lines(bufnr, 8, 9, false, { line(9) })
    end
    if not_rebasing() then
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
  local function get(i) return (vim.api.nvim_buf_get_lines(bufnr, i-1, i, false)[1] or "") end
  local check = M.start .. spaces(M.margin - strlen(M.start)) .. "Updated: "

  if get(9):match("^<<<<<<<") and get(11):match("^=======") and get(13):match("^>>>>>>>")
     and get(10):sub(1, #check) == check then
    local repl = { line(9), line(10), line(11) }
    vim.api.nvim_buf_set_lines(bufnr, 8, 11, false, repl)
    vim.api.nvim_buf_set_lines(bufnr, 11, 15, false, {})
    vim.notify("42header conflicts automatically resolved!", vim.log.levels.INFO)
  elseif get(8):match("^<<<<<<<") and get(11):match("^=======") and get(14):match("^>>>>>>>")
     and get(10):sub(1, #check) == check then
    local repl = { line(8), line(9), line(10), line(11) }
    vim.api.nvim_buf_set_lines(bufnr, 7, 11, false, repl)
    vim.api.nvim_buf_set_lines(bufnr, 11, 16, false, {})
    vim.notify("42header conflicts automatically resolved!", vim.log.levels.INFO)
  end
end

-- Optional: create user command + autocmds from here
function M.setup(opts)
  opts = opts or {}
  if opts.user then M.user42 = opts.user end
  if opts.mail then M.mail42 = opts.mail end

  vim.api.nvim_create_user_command("Stdheader", function() M.stdheader() end, {})
  local aug = vim.api.nvim_create_augroup("stdheader", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", { group = aug, pattern = "*", callback = function() M.update() end })
  vim.api.nvim_create_autocmd("BufReadPost", { group = aug, pattern = "*", callback = function() M.fix_merge_conflict() end })
end

return M

