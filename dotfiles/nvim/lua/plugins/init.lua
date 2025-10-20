-- ~/.config/nvim/lua/plugins/init.lua
return {
  -- Core utils
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

  -- Diagnostics list
  { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },

  -- Indent guides
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- TODO/FIXME highlighting
  { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },

  -- LSP toolchain
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", dependencies = { "williamboman/mason.nvim" } },
  --{
  --  "neovim/nvim-lspconfig",
  --  config = function()
  --    local lspconfig = require("lspconfig")
  --    -- C/C++
  --    lspconfig.clangd.setup({})
  --    -- Lua (Neovim config)
  --    lspconfig.lua_ls.setup({
  --      settings = { Lua = { diagnostics = { globals = { "vim" } } } }
  --    })
  --    -- QML (si qmlls dispo dans ton PATH)
  --    -- lspconfig.qmlls.setup({})
  --  end,
  --},
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Capabilities (garde nvim-cmp si tu l’as)
      local caps = vim.lsp.protocol.make_client_capabilities()
      pcall(function()
        caps = require("cmp_nvim_lsp").default_capabilities(caps)
      end)

      -- Déclare les configs
      vim.lsp.config("clangd", { capabilities = caps })
      vim.lsp.config("lua_ls", {
        capabilities = caps,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })
      -- Active les serveurs
      vim.lsp.enable("clangd")
      vim.lsp.enable("lua_ls")
    end,
  },

  -- Completion + snippets
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" },

  -- Formatter
  { "stevearc/conform.nvim", opts = {} },

  -- Debug
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },

  -- Lang-specific (au choix selon tes besoins)
  -- Qt/QML syntax:
  { "peterhoeg/vim-qml" },
  -- Flutter/Dart:
  -- { "akinsho/flutter-tools.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  -- Rust:
  -- { "mrcjkb/rustaceanvim" },
  -- CMake:
  { "Civitasv/cmake-tools.nvim" },
  -- C++
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
        highlight = { enable = true, additional_vim_regex_highlighting = false },
      })
    end
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
}

