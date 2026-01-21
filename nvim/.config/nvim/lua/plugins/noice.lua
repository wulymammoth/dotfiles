return {
  {
    "folke/noice.nvim",
    config = function(_, opts)
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)

      -- Disable treesitter highlighting inside Noice to avoid query crashes
      local ts = require("noice.text.treesitter")
      ts.has_lang = function()
        return false
      end
      ts.highlight = function() end
    end,
  },
}
