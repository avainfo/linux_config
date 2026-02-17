-- Configuration Catppuccin
-- À placer dans ~/.config/nvim/lua/plugins/catppuccin.lua

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,      -- Charge en premier
    lazy = false,         -- Charge immédiatement (pas lazy)
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        term_colors = true,
        integrations = {
          cmp = true,
          treesitter = true,
          telescope = {
            enabled = true,
          },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
        },
      })
      
      -- Applique le colorscheme
      vim.cmd("colorscheme catppuccin")
      -- Background customisé
      vim.cmd("hi Normal guibg=#1a1a1a")
    end,
  },
}
