return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ui = vim.tbl_deep_extend("force", opts.ui or {}, {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "rounded",
      })
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {
        "python",
      },
      automatic_installation = true,
    },
  },
}
