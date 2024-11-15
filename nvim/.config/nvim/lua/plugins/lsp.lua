-- local function get_python_path()
--   local venv_path = os.getenv("VIRTUAL_ENV")
--
--   if venv_path then
--     -- If a virtual environment is activated, return the path to the Python executable
--     return venv_path .. "/bin/python"
--   else
--     -- Otherwise, fallback to system Python or another preferred interpreter
--     return "/usr/bin/python"
--   end
-- end

local function get_python_path()
  local venv_path = ".venv/bin/python" -- Path within nix-shell

  if vim.fn.filereadable(venv_path) == 1 then
    -- If the .venv exists and is accessible, return the path to the Python executable
    return venv_path
  else
    -- Fallback to system Python or another interpreter
    return "/usr/bin/python"
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
            -- optional settings
            settings = {},
          },
        }
      end

      lspconfig.lexical.setup({})

      -- [Python]

      -- HACK to fix hover (in Python)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
        end,
      })

      -- Get the Poetry virtual environment path
      local poetry_handle = io.popen("poetry env info --path")
      if poetry_handle then
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
      end

      lspconfig.basedpyright.setup({
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
              typeCheckingMode = "strict", -- Enable strict type-checking similar to MyPy's settings
              pythonPath = get_python_path(), -- Dynamically resolved Python path
            },
          },
        },
      })
    end,
  },

  -- nvim-lint setup for MyPy
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("lint").linters_by_ft = {
        python = { "mypy" },
      }

      -- Auto-run linting on save
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
