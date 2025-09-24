-- Override LazyVim's plugin rename warnings by using the new names
-- but pointing them to the original repositories
return {
  -- Use the "new" names that LazyVim expects, but point to original repos
  { "mason-org/mason.nvim", name = "mason.nvim", url = "https://github.com/williamboman/mason.nvim" },
  { "mason-org/mason-lspconfig.nvim", name = "mason-lspconfig.nvim", url = "https://github.com/williamboman/mason-lspconfig.nvim" },
  { "jay-babu/mason-nvim-dap.nvim", url = "https://github.com/jay-babu/mason-nvim-dap.nvim" },
}