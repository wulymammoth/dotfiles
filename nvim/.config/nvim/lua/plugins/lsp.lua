local function get_python_path()
  local home = os.getenv("HOME")
  local venv_path = os.getenv("VIRTUAL_ENV")

  if venv_path then
    -- If a virtual environment is activated, return the path to the Python executable
    return venv_path .. "/bin/python"
  else
    -- Otherwise, fallback to system Python or another preferred interpreter
    return home .. "/.asdf/shims/python"
  end
end

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
            settings = {},
          },
        }
      end

      lspconfig.lexical.setup({})

      -- [Python]

      -- Fix hover in Python
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
        end,
      })

      -- Get the Poetry virtual environment path
      local poetry_venv = nil
      local poetry_handle = io.popen("poetry env info --path 2>/dev/null") -- Ignore errors
      if poetry_handle then
        poetry_venv = poetry_handle:read("*a"):gsub("\n", "")
        poetry_handle:close()
      end

      -- Get the Python version
      local python_version = nil
      local python_handle = io.popen("python --version 2>&1 || python3 --version 2>&1") -- Try both python and python3
      if python_handle then
        python_version = python_handle:read("*a"):gsub("Python ", ""):gsub("\n", "")
        python_handle:close()
      end

      -- Extract the major and minor version
      local python_major_minor = python_version and python_version:match("^(%d+%.%d+)") or nil

      -- Set the PYTHONPATH environment variable dynamically if both values exist
      if poetry_venv and poetry_venv ~= "" and python_major_minor then
        vim.env.PYTHONPATH = string.format("%s/lib/python%s/site-packages", poetry_venv, python_major_minor)
      end

      lspconfig.basedpyright.setup({
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
              pythonPath = get_python_path(), -- Dynamically resolved Python path
            },
          },
        },
      })
    end,
  },
}
