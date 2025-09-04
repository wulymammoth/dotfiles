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
      local mason_lspconfig = require("mason-lspconfig")
      
      -- Global LSP error handling to prevent sync errors
      vim.lsp.set_log_level("error")
      
      -- Add error handler for LSP sync issues
      local original_handler = vim.lsp.handlers["textDocument/didChange"]
      vim.lsp.handlers["textDocument/didChange"] = function(...)
        local ok, result = pcall(original_handler, ...)
        if not ok then
          vim.notify("LSP sync error ignored: " .. tostring(result), vim.log.levels.DEBUG)
        end
        return result
      end

      -- LSP keymaps setup
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
      end

      -- Common LSP setup options to prevent sync issues
      local default_setup = {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        on_attach = on_attach,
        flags = {
          debounce_text_changes = 150, -- Reduce sync frequency
        },
      }

      -- Python-specific setup with Poetry/virtual environment detection
      local python_setup = vim.tbl_deep_extend("force", default_setup, {
        -- Fix hover in Python
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
        end,
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

      -- Expert LSP (Elixir) - manually installed, not managed by Mason
      lspconfig.lexical.setup({
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        cmd = { vim.fn.expand("~/.local/bin/expert") },
        root_dir = function(fname)
          return lspconfig.util.root_pattern("mix.exs", ".git")(fname) or vim.loop.cwd()
        end,
        filetypes = { "elixir", "eelixir", "heex" },
        on_attach = on_attach,
        settings = {}
      })

      -- Mason-managed LSP server configurations
      local server_configs = {
        basedpyright = python_setup,
        ts_ls = default_setup,
        eslint = default_setup,
        lua_ls = vim.tbl_deep_extend("force", default_setup, {
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        }),
        jsonls = default_setup,
        yamlls = default_setup,
      }

      -- Setup LSP servers through mason-lspconfig
      mason_lspconfig.setup_handlers({
        -- Default handler for servers without custom configuration
        function(server_name)
          lspconfig[server_name].setup(default_setup)
        end,
        
        -- Custom configurations for specific servers
        ["basedpyright"] = function()
          lspconfig.basedpyright.setup(server_configs.basedpyright)
        end,
        
        ["ts_ls"] = function()
          lspconfig.ts_ls.setup(server_configs.ts_ls)
        end,
        
        ["eslint"] = function()
          lspconfig.eslint.setup(server_configs.eslint)
        end,
        
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup(server_configs.lua_ls)
        end,
        
        ["jsonls"] = function()
          lspconfig.jsonls.setup(server_configs.jsonls)
        end,
        
        ["yamlls"] = function()
          lspconfig.yamlls.setup(server_configs.yamlls)
        end,
      })
    end,
  },
}
