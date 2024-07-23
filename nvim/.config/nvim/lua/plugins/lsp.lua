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

      -- [Elixir]
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

      -- [Python]
      -- Get the Poetry virtual environment path
      local poetry_handle = io.popen("poetry env info --path")
      local poetry_venv = poetry_handle:read("*a"):gsub("\n", "")
      poetry_handle:close()

      -- Get the Python version
      local python_handle = io.popen("python --version")
      local python_version = python_handle:read("*a"):gsub("Python ", ""):gsub("\n", "")
      python_handle:close()

      -- Extract the major and minor version
      local python_major_minor = python_version:match("^(%d+%.%d+)")

      -- Set the PYTHONPATH environment variable dynamically
      vim.env.PYTHONPATH = poetry_venv .. "/lib/python" .. python_major_minor .. "/site-packages"
    end,
  },
}
