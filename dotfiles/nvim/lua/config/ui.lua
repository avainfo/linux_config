_G.norminette_status = _G.norminette_status or function()
	return ""
end

vim.opt.statusline = table.concat({
	" %f",
	"%m",
	"%=",
	"%{%v:lua.norminette_status()%}",
	" %l,%c",
	" %p%% ",
})
