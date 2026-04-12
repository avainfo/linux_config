-- === CP (Competitive Programming) workflow ===
-- Compile + run avec timing, template auto, terminal split

local M = {}

local function compile(file, out)
    local cmd = string.format(
        "g++ -std=c++20 -O2 -Wall -Wextra -fsanitize=address,undefined -o %s %s 2>&1",
        out, file
    )
    return cmd
end

local function run_in_split(cmd, height)
    height = height or 15
    vim.cmd(string.format("botright %dsplit", height))
    vim.cmd("terminal " .. cmd)
    vim.cmd("startinsert")
end

function M.build()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" or not file:match("%.cpp$") then
        vim.notify("Not a .cpp file", vim.log.levels.WARN)
        return
    end
    vim.cmd("write")
    local out = file:gsub("%.cpp$", "")
    local cmd = compile(file, out)
    vim.fn.jobstart({ "bash", "-c", cmd }, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data and #data > 0 and data[1] ~= "" then
                vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
            end
        end,
        on_exit = function(_, code)
            if code == 0 then
                vim.notify("✓ Compiled: " .. vim.fn.fnamemodify(out, ":t"), vim.log.levels.INFO)
            end
        end,
    })
end

function M.run()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" or not file:match("%.cpp$") then
        vim.notify("Not a .cpp file", vim.log.levels.WARN)
        return
    end
    vim.cmd("write")
    local out = file:gsub("%.cpp$", "")
    local cmd = string.format(
        "g++ -std=c++20 -O2 -Wall -fsanitize=address,undefined -o %s %s && echo '─── Running ───' && { time %s ; }",
        out, file, out
    )
    run_in_split("bash -c " .. vim.fn.shellescape(cmd))
end

function M.run_with_input()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" or not file:match("%.cpp$") then
        vim.notify("Not a .cpp file", vim.log.levels.WARN)
        return
    end
    vim.cmd("write")
    local out  = file:gsub("%.cpp$", "")
    local dir  = vim.fn.fnamemodify(file, ":h")
    local inp  = dir .. "/input.txt"
    local outp = dir .. "/output.txt"

    local redirect
    if vim.fn.filereadable(inp) == 1 then
        redirect = string.format("< %s | tee %s", inp, outp)
        vim.notify("Using input.txt → output.txt", vim.log.levels.INFO)
    else
        redirect = ""
        vim.notify("No input.txt found, running interactively", vim.log.levels.WARN)
    end

    local cmd = string.format(
        "g++ -std=c++20 -O2 -Wall -fsanitize=address,undefined -o %s %s && echo '─── Running ───' && { time %s %s ; }",
        out, file, out, redirect
    )
    run_in_split("bash -c " .. vim.fn.shellescape(cmd))
end

function M.load_template()
    local template = vim.fn.stdpath("config") .. "/templates/cp.cpp"
    if vim.fn.filereadable(template) == 0 then
        vim.notify("Template not found: " .. template, vim.log.levels.ERROR)
        return
    end
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local empty = #lines == 0 or (#lines == 1 and lines[1] == "")
    if empty then
        vim.cmd("read " .. template)
        vim.cmd("1delete _")
		vim.notify("CP template loaded", vim.log.levels.INFO)
    end
end

function M.open_input()
    local file = vim.api.nvim_buf_get_name(0)
    local dir = (file ~= "") and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
    vim.cmd("vsplit " .. dir .. "/input.txt")
end

return M
