return {
  -- Core deps
  "nvim-lua/plenary.nvim",

  -- Treesitter (syntax/AST)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Telescope (finder)
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Statusline
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },

  -- Which-key (discover mappings)
  { "folke/which-key.nvim", opts = {} },

  -- Comments
  { "numToStr/Comment.nvim", opts = {} },

  -- Git signs
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- Diagnostics list (nice UI)
  { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },

  -- Indent guides
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- LSP suite
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", dependencies = { "williamboman/mason.nvim" } },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      -- C/C++
      lspconfig.clangd.setup({})
      -- Lua (pour config Neovim)
      lspconfig.lua_ls.setup({
        settings = { Lua = { diagnostics = { globals = { "vim" } } } }
      })
    end,
  },
}

