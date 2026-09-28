vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

require("config.options")
require("config.lazy")
require("config.ui")
require("config.autocmds")

require("ava.header").setup()
require("config.norminette").setup()
require("config.keymaps")
