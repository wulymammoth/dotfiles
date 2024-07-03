return {
  {
    "neovim/nvim-lspconfig",

    opts = {
      diagnostics = {
        underline = false,
        update_in_insert = false,
        virtual_text = {
          highlight = "Comment",
          prefix = "icons",
          severity = vim.diagnostic.severity.ERROR,
          source = "if_many",
          spacing = 5,
          underline = false,
        },
      },

      -- inline type information
      inlay_hints = {
        aligned = true,
        enabled = true,
        only_current_line = false,
      },
    },

    config = function()
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")

      local home = os.getenv("HOME")
      if not configs.lexical then
        configs.lexical = {
          default_config = {
            filetypes = { "elixir", "eelixir", "heex" },
            cmd = { home .. "/.local/share/nvim/mason/packages/lexical/libexec/lexical/bin/start_lexical.sh" },
            root_dir = function(fname)
              return lspconfig.util.root_pattern("mix.exs", ".git")(fname) or home
            end,
            -- optional settings
            settings = {},
          },
        }
      end

      lspconfig.lexical.setup({})
    end,
  },
}
