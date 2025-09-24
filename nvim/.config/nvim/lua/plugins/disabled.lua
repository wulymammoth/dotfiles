return {
  { "akinsho/bufferline.nvim", enabled = false },
  { "folke/flash.nvim", enabled = false },
  -- Disable LazyVim's default completion plugins since we're using blink.cmp
  { "hrsh7th/nvim-cmp", enabled = false },
  { "hrsh7th/cmp-buffer", enabled = false },
  { "hrsh7th/cmp-nvim-lsp", enabled = false },
  { "hrsh7th/cmp-path", enabled = false },
  { "saadparwaiz1/cmp_luasnip", enabled = false },
  -- Mason plugins re-enabled for LSP management
  -- { "williamboman/mason.nvim", enabled = false },
  -- { "williamboman/mason-lspconfig.nvim", enabled = false },
  -- { "jay-babu/mason-nvim-dap.nvim", enabled = false },
  -- Disable Telescope plugins - using fzf-lua instead
  { "nvim-telescope/telescope.nvim", enabled = false },
  { "nvim-telescope/telescope-live-grep-args.nvim", enabled = false },
  -- Disable nvim-treesitter-refactor due to incompatibility with latest nvim-treesitter
  { "nvim-treesitter/nvim-treesitter-refactor", enabled = false },
}
