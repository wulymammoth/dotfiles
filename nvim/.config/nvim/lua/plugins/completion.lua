return {
  {
    "hrsh7th/nvim-cmp",

    lazy = false,

    priority = 100,

    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "onsails/lspkind.nvim",
      "saadparwaiz1/cmp_luasnip",
      {
        "zbirenbaum/copilot-cmp",
        opts = {
          suggestion = { enable = true },
          panel = { enable = false },
        },
      },
      { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
    },

    config = function()
      require("custom.completion")
    end,
  },
}
