return {
  {
    "folke/trouble.nvim",
    opts = function(_, opts)
      opts.modes = opts.modes or {}

      opts.modes.symbols = vim.tbl_deep_extend("force", opts.modes.symbols or {}, {
        win = {
          position = "right",
          size = { width = 0.35 },
        },
      })

      opts.modes.lsp = vim.tbl_deep_extend("force", opts.modes.lsp or {}, {
        win = {
          position = "right",
          size = { width = 0.4 },
        },
      })
    end,
  },
}
